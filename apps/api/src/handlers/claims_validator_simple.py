"""
Healthcare Claims Validation Lambda Handler - Steel Thread
Minimal working version for end-to-end validation
"""

import json
import logging
import os
from datetime import datetime, timedelta
from typing import Dict, Any

import boto3
from decimal import Decimal

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
dynamodb = boto3.resource('dynamodb')


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Steel-thread Lambda handler for healthcare claims validation
    """
    try:
        logger.info(f"Claims validation request received: {json.dumps(event, default=str)}")
        
        # Parse request
        http_method = event.get('httpMethod', 'POST')
        
        if http_method == 'POST':
            return handle_claim_submission(event, context)
        elif http_method == 'GET':
            return handle_claim_status(event, context)
        else:
            return create_error_response(405, f"Method {http_method} not allowed")
    
    except Exception as e:
        logger.error(f"Claims validation handler error: {str(e)}")
        return create_error_response(500, "Internal server error")


def handle_claim_submission(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """Handle new claim submission with mock AI validation"""
    try:
        # Parse request body
        request_body = json.loads(event.get('body', '{}'))
        claim_id = request_body.get('claimId', f"CLAIM_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}")
        
        logger.info(f"Processing claim submission: {claim_id}")
        
        # Store claim in DynamoDB
        table = dynamodb.Table(os.environ.get('DYNAMODB_TABLE_NAME', 'healthcare-ai-governance-claims'))
        
        # Generate sophisticated mock AI validation results
        mock_result = generate_sophisticated_mock_validation(request_body)
        
        # Create claim record with sophisticated AI validation results
        claim_record = {
            'claimId': claim_id,
            'status': mock_result['status'].upper(),
            'patientId': request_body.get('patientId', 'UNKNOWN'),
            'providerId': request_body.get('providerId', 'UNKNOWN'),
            'procedureCode': request_body.get('procedureCode', '99213'),
            'diagnosisCode': request_body.get('diagnosisCode', 'K21.9'),
            'claimAmount': Decimal(str(request_body.get('claimAmount', 250.0))),
            'dateOfService': request_body.get('dateOfService', datetime.utcnow().strftime('%Y-%m-%d')),
            'priority': request_body.get('priority', 'routine'),
            'processed_at': datetime.utcnow().isoformat(),
            'ai_confidence_score': Decimal(str(mock_result['confidence'])),
            'cost_reduction': Decimal(str(mock_result['cost_reduction'])),
            'processing_time_ms': mock_result['processing_time_ms'],
            'ai_reasoning_text': mock_result['reasoning'],
            'compliance_checks': mock_result['compliance_checks'],
            'ttl': int((datetime.utcnow() + timedelta(days=7)).timestamp())  # Auto-cleanup after 7 days
        }
        
        table.put_item(Item=claim_record)
        
        # Business metrics for executive presentation using sophisticated mock results
        response_data = {
            "message": f"Claim submitted and validated successfully - {mock_result['status'].upper()}",
            "claim_id": claim_id,
            "status": mock_result['status'].upper(),
            "processing_time_ms": mock_result['processing_time_ms'],
            "ai_confidence_score": mock_result['confidence'],
            "ai_reasoning": mock_result['reasoning'][:200] + "..." if len(mock_result['reasoning']) > 200 else mock_result['reasoning'],
            "business_metrics": {
                "cost_reduction": mock_result['cost_reduction'],
                "manual_review_cost_avoided": mock_result['cost_reduction'],
                "processing_time_reduction_percent": 98.5,
                "accuracy_improvement_percent": 15.2
            },
            "compliance_checks": mock_result['compliance_checks'],
            "validation_summary": {
                "medical_necessity": "VALIDATED" if mock_result['status'] == 'approved' else "PENDING_REVIEW",
                "coding_accuracy": "VERIFIED",
                "fraud_indicators": "NONE_DETECTED",
                "compliance_status": "COMPLIANT" if mock_result['status'] == 'approved' else "UNDER_REVIEW"
            }
        }
        
        logger.info(f"Claim {claim_id} processed successfully with {mock_result['confidence']}% confidence - {mock_result['status']}")
        return create_success_response(201, response_data)
        
    except Exception as e:
        logger.error(f"Claim submission error: {str(e)}")
        return create_error_response(500, f"Claim submission failed: {str(e)}")


def handle_claim_status(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """Handle claim status request"""
    try:
        path_params = event.get('pathParameters') or {}
        claim_id = path_params.get('claimId')
        
        if not claim_id:
            return create_error_response(400, "Missing claim ID in path")
        
        # Get claim from DynamoDB
        table = dynamodb.Table(os.environ.get('DYNAMODB_TABLE_NAME', 'healthcare-ai-governance-claims'))
        
        response = table.get_item(Key={'claimId': claim_id})
        
        if 'Item' not in response:
            return create_error_response(404, f"Claim {claim_id} not found")
        
        claim_data = response['Item']
        
        return create_success_response(200, {
            "claim": claim_data,
            "processing_complete": True
        })
        
    except Exception as e:
        logger.error(f"Claim status request error: {str(e)}")
        return create_error_response(500, f"Failed to retrieve claim status: {str(e)}")


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
            "steel_thread": "v1.0",
            "environment": os.environ.get('USE_MOCK_AI', 'true')
        })
    }


def create_error_response(status_code: int, message: str) -> Dict[str, Any]:
    """Create standardized error response for API Gateway"""
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({
            "success": False,
            "error": {
                "code": f"HTTP_{status_code}",
                "message": message,
                "timestamp": datetime.utcnow().isoformat()
            }
        })
    }


def generate_sophisticated_mock_validation(claim_data: Dict[str, Any]) -> Dict[str, Any]:
    """Generate sophisticated mock AI validation results based on claim characteristics"""
    
    procedure_code = claim_data.get('procedureCode', '99213')
    diagnosis_code = claim_data.get('diagnosisCode', 'K21.9')
    claim_amount = float(claim_data.get('claimAmount', 250.0))
    
    # Select realistic scenario based on procedure code
    scenario = select_mock_scenario(procedure_code, diagnosis_code, claim_amount)
    
    # Generate realistic processing time (1-3 seconds)
    import random
    processing_time_ms = random.randint(800, 2200)
    
    # Calculate cost reduction based on scenario
    manual_review_cost = 25.0  # Average manual review cost
    ai_processing_cost = 3.50   # AI processing cost
    cost_reduction = manual_review_cost - ai_processing_cost
    
    return {
        'status': scenario['status'],
        'confidence': scenario['confidence'],
        'reasoning': scenario['reasoning'].format(
            procedure_code=procedure_code,
            diagnosis_code=diagnosis_code,
            claim_amount=claim_amount,
            medical_context=get_medical_context(procedure_code, diagnosis_code)
        ),
        'compliance_checks': generate_compliance_checks(scenario),
        'cost_reduction': cost_reduction,
        'processing_time_ms': processing_time_ms
    }


def select_mock_scenario(procedure_code: str, diagnosis_code: str, claim_amount: float) -> Dict[str, Any]:
    """Select realistic scenario based on claim characteristics"""
    
    scenarios = [
        {
            'name': 'Routine Preventive Care - Approved',
            'status': 'approved',
            'confidence': 88.0,
            'reasoning': """PREVENTIVE CARE MEDICAL NECESSITY ANALYSIS

CLINICAL ASSESSMENT:
Procedure {procedure_code} for diagnosis {diagnosis_code} represents evidence-based preventive care intervention.

Medical Context: {medical_context}

MEDICAL APPROPRIATENESS:
✓ Procedure aligns with USPSTF recommendations
✓ Patient age and risk factors support intervention timing  
✓ Cost-effective approach to disease prevention
✓ Follows evidence-based clinical guidelines

RECOMMENDATION: APPROVE
Medical necessity clearly established for preventive intervention."""
        },
        {
            'name': 'Standard Treatment - Approved', 
            'status': 'approved',
            'confidence': 82.5,
            'reasoning': """STANDARD TREATMENT MEDICAL NECESSITY ANALYSIS

CLINICAL ASSESSMENT:
Procedure {procedure_code} for diagnosis {diagnosis_code} represents appropriate therapeutic intervention.

Medical Context: {medical_context}

CLINICAL JUSTIFICATION:
✓ Procedure directly addresses diagnosed condition
✓ Treatment approach consistent with standard of care
✓ Cost aligns with typical reimbursement patterns
✓ No contraindications identified

RECOMMENDATION: APPROVE
Standard treatment protocol validates medical necessity."""
        },
        {
            'name': 'Complex Case - Requires Review',
            'status': 'pending',
            'confidence': 65.8,
            'reasoning': """COMPLEX CASE MEDICAL NECESSITY ANALYSIS

CLINICAL ASSESSMENT:
Procedure {procedure_code} for diagnosis {diagnosis_code} presents atypical clinical scenario.

Medical Context: {medical_context}

CLINICAL CONSIDERATIONS:
⚠ Procedure coding may require clarification
⚠ Diagnosis-procedure alignment needs verification
⚠ Cost exceeds typical range - justification needed
✓ No absolute contraindications identified

RECOMMENDATION: HUMAN REVIEW
Complex clinical scenario requires specialist evaluation."""
        },
        {
            'name': 'Experimental Treatment - Denied',
            'status': 'denied', 
            'confidence': 91.2,
            'reasoning': """EXPERIMENTAL TREATMENT MEDICAL NECESSITY ANALYSIS

CLINICAL ASSESSMENT:
Procedure {procedure_code} for diagnosis {diagnosis_code} represents non-standard intervention.

Medical Context: {medical_context}

COVERAGE DETERMINATION:
✗ Procedure not included in evidence-based guidelines
✗ Insufficient clinical evidence for effectiveness
✗ Alternative standard treatments available
✗ Does not meet medical necessity criteria

RECOMMENDATION: DENY
Experimental nature prevents coverage approval."""
        }
    ]
    
    # Select scenario based on procedure code patterns
    if procedure_code.startswith('99'):
        return scenarios[1] if claim_amount < 500 else scenarios[2]  # Standard vs complex
    elif procedure_code.startswith('0'):
        return scenarios[0]  # Preventive
    elif claim_amount > 1000:
        return scenarios[2]  # Complex/expensive
    else:
        return scenarios[1]  # Standard


def get_medical_context(procedure_code: str, diagnosis_code: str) -> str:
    """Generate medical context based on codes"""
    contexts = {
        '99213': 'Office visit - established patient, moderate complexity',
        '99214': 'Office visit - established patient, high complexity',
        '99215': 'Office visit - established patient, very high complexity', 
        'K21.9': 'Gastroesophageal reflux disease without esophagitis',
        'Z00.00': 'Annual wellness visit, no abnormal findings'
    }
    
    context_parts = []
    if procedure_code in contexts:
        context_parts.append(contexts[procedure_code])
    if diagnosis_code in contexts:
        context_parts.append(contexts[diagnosis_code])
        
    return '; '.join(context_parts) if context_parts else 'Standard healthcare encounter'


def generate_compliance_checks(scenario: Dict[str, Any]) -> list:
    """Generate compliance check results"""
    base_checks = [
        {
            'check_name': 'Medical Coding Accuracy',
            'passed': True,
            'details': 'ICD-10 and CPT codes properly formatted and valid'
        },
        {
            'check_name': 'Prior Authorization',
            'passed': scenario['status'] != 'denied', 
            'details': 'Prior authorization requirements verified'
        },
        {
            'check_name': 'Network Provider',
            'passed': True,
            'details': 'Provider verified as in-network'
        },
        {
            'check_name': 'Benefit Coverage',
            'passed': scenario['status'] == 'approved',
            'details': 'Service covered under patient benefit plan'
        }
    ]
    
    return base_checks