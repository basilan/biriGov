"""
Cost calculation utilities for budget tracking and ROI demonstration
Critical for maintaining <$50 demo budget compliance
"""

import functools
import logging
from datetime import datetime
from typing import Dict, Any, Callable

from ..config.settings import get_settings
from ..models.healthcare_claim import HealthcareClaim

logger = logging.getLogger(__name__)
settings = get_settings()

# Cost tracking storage (in-memory for demo, would be DynamoDB in production)
_cost_tracking: Dict[str, Dict[str, Any]] = {}


def track_api_cost(api_provider: str) -> Callable:
    """
    Decorator to track API costs for budget monitoring
    
    Args:
        api_provider: Name of API provider ('openai', 'nvidia')
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        async def wrapper(*args, **kwargs) -> Any:
            if not settings.COST_TRACKING_ENABLED:
                return await func(*args, **kwargs)
            
            start_time = datetime.utcnow()
            
            try:
                result = await func(*args, **kwargs)
                
                # Calculate cost based on API provider
                cost = calculate_api_call_cost(api_provider, args, kwargs, result)
                
                # Track cost
                session_id = extract_session_id_from_context(args, kwargs)
                if session_id:
                    await record_cost(session_id, api_provider, cost, func.__name__)
                
                processing_time = (datetime.utcnow() - start_time).total_seconds()
                logger.info(
                    "api_cost_tracked",
                    provider=api_provider,
                    function=func.__name__,
                    cost_usd=cost,
                    processing_time_seconds=processing_time,
                    session_id=session_id
                )
                
                return result
                
            except Exception as e:
                # Still track failed API calls for budget accuracy
                cost = get_failed_api_call_cost(api_provider)
                session_id = extract_session_id_from_context(args, kwargs)
                if session_id:
                    await record_cost(session_id, f"{api_provider}_failed", cost, func.__name__)
                
                raise
        
        return wrapper
    return decorator


def calculate_api_call_cost(provider: str, args: tuple, kwargs: dict, result: Any = None) -> float:
    """
    Calculate cost for specific API call based on provider and usage
    
    Args:
        provider: API provider name
        args: Function arguments
        kwargs: Function keyword arguments  
        result: Function result for usage calculation
        
    Returns:
        Estimated cost in USD
    """
    if provider == 'openai':
        return calculate_openai_cost(args, kwargs, result)
    elif provider == 'nvidia':
        return calculate_nvidia_cost(args, kwargs, result)
    else:
        logger.warning(f"Unknown API provider for cost calculation: {provider}")
        return 0.05  # Default estimate


def calculate_openai_cost(args: tuple, kwargs: dict, result: Any = None) -> float:
    """Calculate OpenAI API call cost based on token usage"""
    # Base cost for GPT-4 API call
    base_cost = 0.03  # Per request
    
    # Additional cost based on response length
    if result and isinstance(result, tuple) and len(result) > 0:
        response_text = str(result[0])  # reasoning text
        # Approximate token calculation (1 token ≈ 4 characters)
        tokens = len(response_text) / 4
        token_cost = tokens * 0.00003  # GPT-4 pricing
        return base_cost + token_cost
    
    return base_cost


def calculate_nvidia_cost(args: tuple, kwargs: dict, result: Any = None) -> float:
    """Calculate NVIDIA AI Enterprise API call cost"""
    # Base cost per compliance check
    base_cost = 0.10
    
    # Additional cost for complex compliance validations
    if result and isinstance(result, list):
        num_checks = len(result)
        return base_cost * num_checks
    
    return base_cost


def get_failed_api_call_cost(provider: str) -> float:
    """Get cost estimate for failed API calls"""
    if provider == 'openai':
        return 0.01  # Minimal cost for failed OpenAI calls
    elif provider == 'nvidia':
        return 0.05  # Minimal cost for failed NVIDIA calls
    return 0.01


async def record_cost(session_id: str, cost_type: str, amount: float, operation: str):
    """
    Record cost for session tracking and budget monitoring
    
    Args:
        session_id: Demonstration session ID
        cost_type: Type of cost (openai, nvidia, aws)
        amount: Cost amount in USD
        operation: Operation that incurred the cost
    """
    if session_id not in _cost_tracking:
        _cost_tracking[session_id] = {
            'total_cost': 0.0,
            'costs_by_type': {},
            'operations': [],
            'created_at': datetime.utcnow().isoformat()
        }
    
    session_costs = _cost_tracking[session_id]
    session_costs['total_cost'] += amount
    
    if cost_type not in session_costs['costs_by_type']:
        session_costs['costs_by_type'][cost_type] = 0.0
    session_costs['costs_by_type'][cost_type] += amount
    
    session_costs['operations'].append({
        'operation': operation,
        'cost_type': cost_type,
        'amount': amount,
        'timestamp': datetime.utcnow().isoformat()
    })
    
    # Check budget warning threshold
    if session_costs['total_cost'] >= settings.BUDGET_WARNING_THRESHOLD_USD:
        logger.warning(
            "budget_warning_threshold_reached",
            session_id=session_id,
            current_cost=session_costs['total_cost'],
            threshold=settings.BUDGET_WARNING_THRESHOLD_USD
        )
    
    # Check budget limit
    if session_costs['total_cost'] >= settings.MAX_DEMO_BUDGET_USD:
        logger.error(
            "budget_limit_exceeded",
            session_id=session_id,
            current_cost=session_costs['total_cost'],
            limit=settings.MAX_DEMO_BUDGET_USD
        )


async def get_session_cost(session_id: str) -> float:
    """
    Get total cost for demonstration session
    
    Args:
        session_id: Demonstration session ID
        
    Returns:
        Total cost in USD
    """
    if session_id in _cost_tracking:
        return _cost_tracking[session_id]['total_cost']
    return 0.0


async def get_session_cost_breakdown(session_id: str) -> Dict[str, Any]:
    """
    Get detailed cost breakdown for session
    
    Args:
        session_id: Demonstration session ID
        
    Returns:
        Cost breakdown dictionary
    """
    if session_id not in _cost_tracking:
        return {
            'total_cost': 0.0,
            'costs_by_type': {},
            'operations': [],
            'budget_remaining': settings.MAX_DEMO_BUDGET_USD
        }
    
    session_costs = _cost_tracking[session_id]
    return {
        **session_costs,
        'budget_remaining': settings.MAX_DEMO_BUDGET_USD - session_costs['total_cost'],
        'budget_utilization_percentage': (session_costs['total_cost'] / settings.MAX_DEMO_BUDGET_USD) * 100
    }


def calculate_cost_savings(manual_cost: float, ai_cost: float) -> Dict[str, float]:
    """
    Calculate cost savings for executive presentation
    
    Args:
        manual_cost: Cost of manual review process
        ai_cost: Cost of AI-powered validation
        
    Returns:
        Cost savings metrics
    """
    if manual_cost <= 0:
        return {
            'cost_reduction_usd': 0.0,
            'cost_reduction_percentage': 0.0,
            'roi_percentage': 0.0
        }
    
    cost_reduction_usd = manual_cost - ai_cost
    cost_reduction_percentage = (cost_reduction_usd / manual_cost) * 100
    roi_percentage = (cost_reduction_usd / ai_cost) * 100 if ai_cost > 0 else 0
    
    return {
        'cost_reduction_usd': round(cost_reduction_usd, 2),
        'cost_reduction_percentage': round(cost_reduction_percentage, 1),
        'roi_percentage': round(roi_percentage, 1)
    }


def estimate_processing_cost(claim: HealthcareClaim) -> float:
    """
    Estimate total processing cost for a healthcare claim
    
    Args:
        claim: HealthcareClaim to estimate cost for
        
    Returns:
        Estimated cost in USD
    """
    base_cost = 0.05  # Base processing cost
    
    # OpenAI cost estimate
    openai_cost = 0.03
    if claim.medical_necessity_context:
        # Additional cost for longer context
        context_length = len(claim.medical_necessity_context)
        openai_cost += (context_length / 1000) * 0.01
    
    # NVIDIA compliance cost estimate
    nvidia_cost = 0.10  # Standard compliance checks
    
    # Priority multiplier
    priority_multiplier = 1.0
    if claim.priority.value == 'urgent':
        priority_multiplier = 1.2
    elif claim.priority.value == 'emergency':
        priority_multiplier = 1.5
    
    total_cost = (base_cost + openai_cost + nvidia_cost) * priority_multiplier
    return round(total_cost, 3)


def extract_session_id_from_context(args: tuple, kwargs: dict) -> str:
    """Extract session ID from function arguments for cost tracking"""
    # Look for session_id in kwargs
    if 'session_id' in kwargs:
        return kwargs['session_id']
    
    # Look for claim object with derivable session info
    for arg in args:
        if hasattr(arg, 'claim_id'):
            # Generate session ID from claim ID for demo purposes
            return f"DEMO_SESSION_{arg.claim_id.split('_')[1]}"
        elif isinstance(arg, dict) and 'claim_id' in arg:
            return f"DEMO_SESSION_{arg['claim_id'].split('_')[1]}"
    
    # Default session for cost tracking
    return "DEFAULT_DEMO_SESSION"


async def reset_session_costs(session_id: str):
    """Reset cost tracking for session (useful for testing)"""
    if session_id in _cost_tracking:
        del _cost_tracking[session_id]
        logger.info(f"Reset cost tracking for session {session_id}")


def get_budget_status() -> Dict[str, Any]:
    """Get overall budget status across all sessions"""
    total_costs = sum(session_data['total_cost'] for session_data in _cost_tracking.values())
    
    return {
        'total_costs_across_sessions': total_costs,
        'max_demo_budget': settings.MAX_DEMO_BUDGET_USD,
        'remaining_budget': settings.MAX_DEMO_BUDGET_USD - total_costs,
        'active_sessions': len(_cost_tracking),
        'budget_utilization_percentage': (total_costs / settings.MAX_DEMO_BUDGET_USD) * 100
    }