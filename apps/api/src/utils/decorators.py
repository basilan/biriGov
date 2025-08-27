"""
Common decorators for Healthcare AI Governance Agent
Implements healthcare audit trails and error handling per coding standards
"""

import functools
import logging
import time
from datetime import datetime
from typing import Any, Callable, Dict, Optional

import structlog
from ..config.settings import get_settings

logger = structlog.get_logger()
settings = get_settings()


def handle_errors(func: Callable) -> Callable:
    """
    Standard error handler decorator for all API routes
    Implements consistent healthcare audit trail and compliance logging
    """
    @functools.wraps(func)
    async def wrapper(*args, **kwargs) -> Any:
        start_time = time.time()
        request_id = generate_request_id()
        
        try:
            # Log function entry for audit trail
            logger.info(
                "function_entry",
                function_name=func.__name__,
                request_id=request_id,
                timestamp=datetime.utcnow().isoformat(),
                args_count=len(args),
                kwargs_keys=list(kwargs.keys())
            )
            
            # Execute function
            result = await func(*args, **kwargs)
            
            # Log successful completion
            execution_time = time.time() - start_time
            logger.info(
                "function_success", 
                function_name=func.__name__,
                request_id=request_id,
                execution_time_ms=round(execution_time * 1000, 2),
                timestamp=datetime.utcnow().isoformat()
            )
            
            return result
            
        except Exception as e:
            # Log error with full context for healthcare compliance
            execution_time = time.time() - start_time
            logger.error(
                "function_error",
                function_name=func.__name__,
                request_id=request_id,
                error_type=type(e).__name__,
                error_message=str(e),
                execution_time_ms=round(execution_time * 1000, 2),
                timestamp=datetime.utcnow().isoformat(),
                # Note: No patient data in error logs per HIPAA compliance
                exc_info=True
            )
            raise
    
    return wrapper


def audit_trail(operation_type: str, include_response: bool = False) -> Callable:
    """
    Healthcare audit trail decorator for regulatory compliance demonstration
    
    Args:
        operation_type: Type of operation for audit categorization
        include_response: Whether to include response in audit log
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        async def wrapper(*args, **kwargs) -> Any:
            audit_id = generate_audit_id()
            start_time = datetime.utcnow()
            
            # Extract claim ID from args/kwargs if available
            claim_id = extract_claim_id(args, kwargs)
            
            try:
                # Log audit entry
                logger.info(
                    "audit_trail_entry",
                    audit_id=audit_id,
                    operation_type=operation_type,
                    function_name=func.__name__,
                    claim_id=claim_id,
                    user_context=get_user_context(kwargs),
                    timestamp=start_time.isoformat(),
                    compliance_event=True
                )
                
                # Execute function
                result = await func(*args, **kwargs)
                
                # Log audit completion
                end_time = datetime.utcnow()
                processing_time = (end_time - start_time).total_seconds()
                
                audit_log_data = {
                    "audit_id": audit_id,
                    "operation_type": operation_type,
                    "function_name": func.__name__,
                    "claim_id": claim_id,
                    "status": "completed",
                    "processing_time_seconds": processing_time,
                    "timestamp": end_time.isoformat(),
                    "compliance_event": True
                }
                
                if include_response and result:
                    # Include sanitized response (no patient data)
                    audit_log_data["response_summary"] = sanitize_response_for_audit(result)
                
                logger.info("audit_trail_completion", **audit_log_data)
                
                return result
                
            except Exception as e:
                # Log audit failure
                end_time = datetime.utcnow()
                processing_time = (end_time - start_time).total_seconds()
                
                logger.error(
                    "audit_trail_failure",
                    audit_id=audit_id,
                    operation_type=operation_type,
                    function_name=func.__name__,
                    claim_id=claim_id,
                    error_type=type(e).__name__,
                    error_message=str(e),
                    processing_time_seconds=processing_time,
                    timestamp=end_time.isoformat(),
                    compliance_event=True
                )
                raise
        
        return wrapper
    return decorator


def log_execution_time(func: Callable) -> Callable:
    """
    Log function execution time for performance monitoring
    """
    @functools.wraps(func)
    async def wrapper(*args, **kwargs) -> Any:
        start_time = time.time()
        
        result = await func(*args, **kwargs)
        
        execution_time = time.time() - start_time
        logger.info(
            "performance_metric",
            function_name=func.__name__,
            execution_time_ms=round(execution_time * 1000, 2),
            timestamp=datetime.utcnow().isoformat()
        )
        
        return result
    
    return wrapper


def validate_demo_budget(func: Callable) -> Callable:
    """
    Validate that operation doesn't exceed demo budget
    Critical for $50 budget compliance
    """
    @functools.wraps(func)
    async def wrapper(*args, **kwargs) -> Any:
        if settings.COST_TRACKING_ENABLED:
            # Check current session cost
            session_id = extract_session_id(args, kwargs)
            if session_id:
                current_cost = await get_session_cost(session_id)
                if current_cost >= settings.BUDGET_WARNING_THRESHOLD_USD:
                    logger.warning(
                        "budget_warning",
                        session_id=session_id,
                        current_cost=current_cost,
                        threshold=settings.BUDGET_WARNING_THRESHOLD_USD,
                        function_name=func.__name__
                    )
                    
                if current_cost >= settings.MAX_DEMO_BUDGET_USD:
                    logger.error(
                        "budget_exceeded",
                        session_id=session_id,
                        current_cost=current_cost,
                        max_budget=settings.MAX_DEMO_BUDGET_USD
                    )
                    raise ValueError(f"Demo budget exceeded: ${current_cost:.2f} >= ${settings.MAX_DEMO_BUDGET_USD}")
        
        return await func(*args, **kwargs)
    
    return wrapper


# Utility functions for decorators

def generate_request_id() -> str:
    """Generate unique request ID for tracing"""
    import uuid
    return f"req_{int(time.time())}_{str(uuid.uuid4())[:8]}"


def generate_audit_id() -> str:
    """Generate unique audit ID for compliance tracking"""
    import uuid
    return f"audit_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}_{str(uuid.uuid4())[:8]}"


def extract_claim_id(args: tuple, kwargs: dict) -> Optional[str]:
    """Extract claim ID from function arguments for audit logging"""
    # Look for claim_id in kwargs
    if 'claim_id' in kwargs:
        return kwargs['claim_id']
    
    # Look for claim object with claim_id attribute
    for arg in args:
        if hasattr(arg, 'claim_id'):
            return arg.claim_id
        elif isinstance(arg, dict) and 'claim_id' in arg:
            return arg['claim_id']
    
    return None


def extract_session_id(args: tuple, kwargs: dict) -> Optional[str]:
    """Extract session ID from function arguments for budget tracking"""
    if 'session_id' in kwargs:
        return kwargs['session_id']
    
    for arg in args:
        if hasattr(arg, 'session_id'):
            return arg.session_id
        elif isinstance(arg, dict) and 'session_id' in arg:
            return arg['session_id']
    
    return None


def get_user_context(kwargs: dict) -> Dict[str, Any]:
    """Extract user context for audit logging (HIPAA compliant)"""
    return {
        "user_agent": kwargs.get('user_agent', 'unknown'),
        "source_ip": kwargs.get('source_ip', 'unknown'),
        "timestamp": datetime.utcnow().isoformat()
    }


def sanitize_response_for_audit(response: Any) -> Dict[str, Any]:
    """
    Sanitize response for audit logging (remove sensitive data)
    Ensures HIPAA compliance by excluding patient identifiers
    """
    if hasattr(response, 'dict'):
        response_dict = response.dict()
    elif isinstance(response, dict):
        response_dict = response
    else:
        return {"response_type": type(response).__name__}
    
    # Remove sensitive fields
    sanitized = {}
    safe_fields = [
        'result_id', 'claim_id', 'validation_status', 'confidence_score',
        'processing_time_ms', 'business_metrics', 'compliance_checks'
    ]
    
    for field in safe_fields:
        if field in response_dict:
            sanitized[field] = response_dict[field]
    
    return sanitized


async def get_session_cost(session_id: str) -> float:
    """Get current cost for session (placeholder for actual cost service)"""
    # This would integrate with actual cost tracking service
    # For now, return a placeholder value
    return 0.0