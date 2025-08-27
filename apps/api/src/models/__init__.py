"""
Healthcare AI Governance Agent - Python Data Models
Python equivalents of TypeScript interfaces for consistent data handling
"""

from .healthcare_claim import (
    ClaimPriority,
    ClaimStatus,
    HealthcareClaim,
    generate_claim_id,
    validate_claim_id
)

from .validation_result import (
    ValidationStatus,
    ComplianceCheck,
    BusinessMetrics,
    ValidationResult,
    generate_result_id,
    validate_validation_result
)

from .demonstration_session import (
    SystemStatus,
    PresentationMetrics,
    InfrastructureStatus,
    DemonstrationSession,
    generate_session_id,
    calculate_cost_reduction,
    validate_demonstration_session
)

__all__ = [
    # Healthcare Claim
    "ClaimPriority",
    "ClaimStatus", 
    "HealthcareClaim",
    "generate_claim_id",
    "validate_claim_id",
    
    # Validation Result
    "ValidationStatus",
    "ComplianceCheck",
    "BusinessMetrics",
    "ValidationResult",
    "generate_result_id",
    "validate_validation_result",
    
    # Demonstration Session
    "SystemStatus",
    "PresentationMetrics",
    "InfrastructureStatus",
    "DemonstrationSession",
    "generate_session_id",
    "calculate_cost_reduction",
    "validate_demonstration_session"
]