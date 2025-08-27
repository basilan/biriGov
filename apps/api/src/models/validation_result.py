"""
Validation result data models for AI-powered healthcare claims processing
"""

from datetime import datetime
from enum import Enum
from typing import List
from pydantic import BaseModel, Field, validator
import random


class ValidationStatus(str, Enum):
    """AI validation decision status"""
    APPROVED = "approved"
    DENIED = "denied" 
    PARTIAL_APPROVAL = "partial_approval"
    COMPLIANCE_VIOLATION = "compliance_violation"
    INSUFFICIENT_DATA = "insufficient_data"


class ComplianceCheck(BaseModel):
    """NVIDIA AI Enterprise compliance check result"""
    
    check_type: str = Field(..., description="Type of compliance check performed")
    passed: bool = Field(..., description="Whether the check passed")
    details: str = Field(..., description="Detailed compliance check results")
    regulatory_framework: str = Field(..., description="Regulatory framework used (e.g., HIPAA, FDA)")

    class Config:
        use_enum_values = True


class BusinessMetrics(BaseModel):
    """Business metrics for executive presentation"""
    
    manual_review_cost_avoided: float = Field(..., ge=0, description="Cost avoided by using AI vs manual review")
    processing_time_reduction: float = Field(..., ge=0, le=100, description="Time reduction percentage vs manual process")
    accuracy_improvement: float = Field(..., ge=0, le=100, description="AI accuracy improvement over manual consistency")

    class Config:
        use_enum_values = True


class ValidationResult(BaseModel):
    """
    AI validation outcome combining OpenAI medical reasoning with 
    NVIDIA compliance checking for executive demonstration
    """
    
    result_id: str = Field(..., pattern=r"^RESULT_\d{8}_\d{3}$", description="Unique validation result identifier")
    claim_id: str = Field(..., pattern=r"^CLAIM_\d{8}_\d{3}$", description="Reference to source claim")
    validation_status: ValidationStatus = Field(..., description="Final validation decision")
    confidence_score: float = Field(..., ge=0, le=100, description="AI confidence percentage (0-100)")
    cost_reduction: float = Field(..., ge=0, description="Calculated savings vs manual review in USD")
    processing_time_ms: int = Field(..., gt=0, description="Total validation time in milliseconds")
    ai_reasoning_text: str = Field(..., min_length=1, description="OpenAI medical necessity explanation")
    compliance_checks: List[ComplianceCheck] = Field(..., description="NVIDIA compliance validation results")
    created_at: datetime = Field(..., description="Validation completion timestamp")
    requires_human_review: bool = Field(..., description="Whether human review is recommended")
    business_metrics: BusinessMetrics = Field(..., description="Executive presentation metrics")

    class Config:
        use_enum_values = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }

    @validator('confidence_score')
    def validate_confidence_range(cls, v):
        """Ensure confidence score is within valid range"""
        if not 0 <= v <= 100:
            raise ValueError('Confidence score must be between 0 and 100')
        return round(v, 1)

    @validator('processing_time_ms')
    def validate_processing_time_reasonable(cls, v):
        """Ensure processing time is within expected ranges"""
        if v > 300000:  # 5 minutes max
            raise ValueError('Processing time exceeds maximum allowed (5 minutes)')
        return v

    @validator('created_at')
    def validate_created_at_not_future(cls, v):
        """Ensure creation timestamp is not in the future"""
        if v > datetime.utcnow():
            raise ValueError('Creation timestamp cannot be in the future')
        return v

    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization"""
        return self.dict(by_alias=True)

    def is_approved(self) -> bool:
        """Check if validation resulted in approval"""
        return self.validation_status in [ValidationStatus.APPROVED, ValidationStatus.PARTIAL_APPROVAL]

    def get_executive_summary(self) -> dict:
        """Generate executive-focused summary for presentations"""
        return {
            "status": self.validation_status.value,
            "confidence": f"{self.confidence_score}%",
            "cost_savings": f"${self.cost_reduction:.2f}",
            "processing_time": f"{self.processing_time_ms / 1000:.1f}s",
            "compliance_passed": all(check.passed for check in self.compliance_checks),
            "recommendation": "Approved" if self.is_approved() else "Requires Review"
        }

    def calculate_roi_percentage(self, manual_cost: float = 20.0) -> float:
        """Calculate ROI percentage for executive metrics"""
        if manual_cost <= 0:
            return 0.0
        return round((self.cost_reduction / manual_cost) * 100, 1)


def generate_result_id() -> str:
    """Create a valid result ID with current timestamp"""
    date = datetime.now().strftime('%Y%m%d')
    sequence = f"{random.randint(0, 999):03d}"
    return f"RESULT_{date}_{sequence}"


def validate_validation_result(result_data: dict) -> bool:
    """Validate ValidationResult data structure"""
    try:
        ValidationResult(**result_data)
        return True
    except Exception:
        return False