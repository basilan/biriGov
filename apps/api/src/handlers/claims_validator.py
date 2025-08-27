"""
Healthcare Claims Validation Lambda Handler
Main orchestrator for OpenAI + NVIDIA AI claims validation workflow
"""

import json
import logging
from datetime import datetime
from typing import Dict, Any

from ..config.settings import get_settings
from ..models.healthcare_claim import HealthcareClaim, ClaimStatus
from ..models.validation_result import ValidationResult, BusinessMetrics, ValidationStatus
from ..services.ai_service import AIService
from ..services.claims_service import ClaimsService
from ..utils.decorators import handle_errors, audit_trail, log_execution_time
from ..utils.cost_calculator import calculate_cost_savings, estimate_processing_cost

logger = logging.getLogger(__name__)
settings = get_settings()


@handle_errors
@audit_trail("CLAIMS_VALIDATION", include_response=True)
@log_execution_time
async def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    AWS Lambda handler for healthcare claims validation
    
    Orchestrates complete validation workflow:
    1. Parse and validate claim data
    2. OpenAI medical necessity reasoning
    3. NVIDIA compliance validation
    4. Generate executive presentation results
    5. Store results with audit trail
    
    Args:
        event: API Gateway event with claim data
        context: Lambda execution context
        
    Returns:
        API Gateway response with validation results
    """
    
    # Initialize services
    ai_service = AIService()
    claims_service = ClaimsService()
    
    try:
        # Parse request
        request_body = json.loads(event.get('body', '{}'))
        http_method = event.get('httpMethod', 'GET')
        path_parameters = event.get('pathParameters') or {}
        
        logger.info(
            "claims_validation_request",
            http_method=http_method,
            path=event.get('path', ''),
            claim_data_provided=bool(request_body)
        )
        
        if http_method == 'POST':
            # Submit new claim for validation
            return await handle_claim_submission(request_body, ai_service, claims_service)
            
        elif http_method == 'GET':
            # Get claim validation status
            claim_id = path_parameters.get('claimId')
            if not claim_id:
                return create_error_response(400, "Missing claim ID in path")
                
            return await handle_claim_status_request(claim_id, claims_service)
            
        else:
            return create_error_response(405, f"Method {http_method} not allowed")
    
    except Exception as e:
        logger.error(f"Claims validation handler error: {str(e)}")
        return create_error_response(500, "Internal server error", str(e))
    
    finally:
        # Clean up service connections
        await ai_service.close()


async def handle_claim_submission(
    request_data: Dict[str, Any], 
    ai_service: AIService, 
    claims_service: ClaimsService
) -> Dict[str, Any]:
    """
    Handle new claim submission and initiate validation workflow
    """
    try:
        # Parse and validate claim data
        claim = HealthcareClaim.parse_obj(request_data)
        
        logger.info(
            "claim_submission_received",
            claim_id=claim.claim_id,
            procedure_code=claim.procedure_code,
            diagnosis_code=claim.diagnosis_code,
            claim_amount=claim.claim_amount,
            priority=claim.priority.value
        )
        
        # Estimate processing cost for budget tracking
        estimated_cost = estimate_processing_cost(claim)
        if estimated_cost > settings.MAX_DEMO_BUDGET_USD:
            return create_error_response(
                400, 
                f"Estimated processing cost ${estimated_cost:.2f} exceeds demo budget ${settings.MAX_DEMO_BUDGET_USD}"
            )
        
        # Update claim status to processing
        claim.status = ClaimStatus.PROCESSING
        await claims_service.store_claim(claim)
        
        # Start async validation workflow
        validation_result = await perform_claim_validation(claim, ai_service)
        
        # Store validation result
        await claims_service.store_validation_result(validation_result)
        
        # Update claim status
        claim.status = ClaimStatus.AI_REVIEW if validation_result.requires_human_review else validation_result.validation_status.value
        await claims_service.update_claim_status(claim.claim_id, claim.status)
        
        # Return immediate response for API Gateway
        return create_success_response(202, {
            "message": "Claim submitted for validation",
            "claim_id": claim.claim_id,
            "status": claim.status.value,
            "estimated_processing_time_seconds": 120,
            "estimated_cost": estimated_cost
        })
        
    except ValueError as e:
        return create_error_response(400, "Invalid claim data", str(e))
    except Exception as e:
        logger.error(f"Claim submission error: {str(e)}")
        return create_error_response(500, "Claim submission failed", str(e))


async def handle_claim_status_request(claim_id: str, claims_service: ClaimsService) -> Dict[str, Any]:
    """
    Handle claim status and validation results request
    """
    try:
        # Get claim data
        claim = await claims_service.get_claim(claim_id)
        if not claim:
            return create_error_response(404, f"Claim {claim_id} not found")
        
        # Get validation results if available
        validation_result = await claims_service.get_validation_result(claim_id)
        
        response_data = {
            "claim": claim.to_dict(),
            "status": claim.status.value,
            "validation": validation_result.to_dict() if validation_result else None,
            "processing_progress": calculate_processing_progress(claim, validation_result)
        }
        
        return create_success_response(200, response_data)
        
    except Exception as e:
        logger.error(f"Claim status request error: {str(e)}")
        return create_error_response(500, "Failed to retrieve claim status", str(e))


async def perform_claim_validation(claim: HealthcareClaim, ai_service: AIService) -> ValidationResult:
    """
    Perform complete claim validation using OpenAI + NVIDIA AI
    """
    start_time = datetime.utcnow()
    
    # Step 1: OpenAI medical reasoning
    reasoning_text, confidence_score, validation_status = await ai_service.get_medical_reasoning(claim)
    
    # Step 2: NVIDIA compliance validation  
    compliance_checks = await ai_service.validate_compliance(claim, reasoning_text)
    
    # Step 3: Calculate business metrics
    business_metrics = calculate_business_metrics(claim, confidence_score)
    
    # Step 4: Generate final validation result
    end_time = datetime.utcnow()
    processing_time_ms = int((end_time - start_time).total_seconds() * 1000)
    
    result_id = f"RESULT_{datetime.utcnow().strftime('%Y%m%d')}_{claim.claim_id.split('_')[-1]}"
    
    validation_result = ValidationResult(
        result_id=result_id,
        claim_id=claim.claim_id,
        validation_status=validation_status,
        confidence_score=confidence_score,
        cost_reduction=business_metrics.manual_review_cost_avoided,
        processing_time_ms=processing_time_ms,
        ai_reasoning_text=reasoning_text,
        compliance_checks=compliance_checks,
        created_at=end_time,
        requires_human_review=confidence_score < 70 or not all(check.passed for check in compliance_checks),
        business_metrics=business_metrics
    )
    
    logger.info(
        "claim_validation_completed",
        claim_id=claim.claim_id,
        result_id=result_id,
        validation_status=validation_status.value,
        confidence_score=confidence_score,
        processing_time_ms=processing_time_ms,
        compliance_checks_passed=sum(1 for check in compliance_checks if check.passed),
        requires_human_review=validation_result.requires_human_review
    )
    
    return validation_result


def calculate_business_metrics(claim: HealthcareClaim, confidence_score: float) -> BusinessMetrics:
    """
    Calculate executive presentation metrics for ROI demonstration
    """
    # Manual review cost avoided (target: 60% reduction)
    manual_cost = 20.0  # Average manual review cost
    ai_cost = claim.get_estimated_processing_cost()
    cost_avoided = manual_cost - ai_cost
    
    # Processing time reduction (3-7 days to 2 minutes)
    manual_time_hours = 4 * 24  # 4 days average
    ai_time_hours = 2 / 60  # 2 minutes
    time_reduction = ((manual_time_hours - ai_time_hours) / manual_time_hours) * 100
    
    # Accuracy improvement (15-20% manual inconsistency vs AI confidence)
    manual_consistency = 82.5  # 17.5% inconsistency
    accuracy_improvement = max(0, confidence_score - manual_consistency)
    
    return BusinessMetrics(
        manual_review_cost_avoided=cost_avoided,
        processing_time_reduction=min(99.9, time_reduction),
        accuracy_improvement=min(25.0, accuracy_improvement)
    )


def calculate_processing_progress(claim: HealthcareClaim, validation_result: ValidationResult = None) -> Dict[str, Any]:
    """
    Calculate processing progress for real-time UI updates
    """
    if validation_result:
        return {
            "stage": "complete",
            "completion_percentage": 100,
            "current_step": "Validation completed",
            "estimated_remaining_seconds": 0
        }
    
    if claim.status == ClaimStatus.AI_REVIEW:
        return {
            "stage": "ai_reasoning", 
            "completion_percentage": 50,
            "current_step": "AI medical reasoning in progress",
            "estimated_remaining_seconds": 60
        }
    
    if claim.status == ClaimStatus.PROCESSING:
        return {
            "stage": "submitted",
            "completion_percentage": 10,
            "current_step": "Claim validation initiated", 
            "estimated_remaining_seconds": 120
        }
    
    return {
        "stage": "submitted",
        "completion_percentage": 0,
        "current_step": "Awaiting processing",
        "estimated_remaining_seconds": 120
    }


def create_success_response(status_code: int, data: Dict[str, Any]) -> Dict[str, Any]:
    """Create standardized success response for API Gateway"""
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key",
            "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS"
        },
        "body": json.dumps({
            "success": True,
            "data": data,
            "timestamp": datetime.utcnow().isoformat(),
            "request_id": getattr(lambda_handler, '_request_id', 'unknown')
        })
    }


def create_error_response(status_code: int, message: str, details: str = None) -> Dict[str, Any]:
    """Create standardized error response for API Gateway"""
    error_data = {
        "error": {
            "code": f"HTTP_{status_code}",
            "message": message,
            "timestamp": datetime.utcnow().isoformat(),
            "request_id": getattr(lambda_handler, '_request_id', 'unknown')
        }
    }
    
    if details and settings.DEBUG:
        error_data["error"]["details"] = details
    
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(error_data)
    }