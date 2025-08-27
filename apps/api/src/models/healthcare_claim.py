"""
Healthcare Claim Models
Python equivalents of TypeScript interfaces from packages/shared/src/types/healthcare-claim.ts
"""

from datetime import datetime
from enum import Enum
from typing import List, Optional
from pydantic import BaseModel, Field, validator
import re
import random


class ClaimPriority(str, Enum):
    """Healthcare claim priority levels for processing urgency"""
    ROUTINE = "routine"
    URGENT = "urgent"
    EMERGENCY = "emergency"


class ClaimStatus(str, Enum):
    """Healthcare claim processing status"""
    SUBMITTED = "submitted"
    PROCESSING = "processing"
    AI_REVIEW = "ai_review"
    APPROVED = "approved"
    DENIED = "denied"
    REQUIRES_HUMAN_REVIEW = "requires_human_review"


class HealthcareClaim(BaseModel):
    """
    Primary business entity representing a medical claim requiring validation
    against healthcare guidelines for cost reduction demonstration
    """
    
    claim_id: str = Field(..., pattern=r"^CLAIM_\d{8}_\d{3}$", description="Unique claim identifier (format: CLAIM_YYYYMMDD_NNN)")
    patient_id: str = Field(..., pattern=r"^DEMO_PATIENT_\d+$", description="De-identified patient reference")
    provider_id: str = Field(..., pattern=r"^PROV_\d+$", description="Healthcare provider identifier")
    service_date: datetime = Field(..., description="Date of medical service")
    procedure_code: str = Field(..., pattern=r"^\d{5}$", description="CPT/HCPCS procedure code (5 digits)")
    diagnosis_code: str = Field(..., pattern=r"^[A-Z]\d{2}\.\d$", description="ICD-10 diagnosis code (format: A00.0)")
    claim_amount: float = Field(..., gt=0, description="Requested reimbursement amount in USD")
    status: ClaimStatus = Field(..., description="Current validation state")
    submitted_at: datetime = Field(..., description="Initial submission timestamp")
    priority: ClaimPriority = Field(..., description="Processing urgency level")
    medical_necessity_context: Optional[str] = Field(None, description="Optional medical context for AI reasoning")
    supporting_documents: Optional[List[str]] = Field(None, description="Optional supporting document references")

    class Config:
        """Pydantic configuration"""
        use_enum_values = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }

    @validator('service_date', 'submitted_at')
    def validate_datetime_not_future(cls, v):
        """Ensure dates are not in the future"""
        if v > datetime.utcnow():
            raise ValueError('Date cannot be in the future')
        return v

    @validator('claim_amount')
    def validate_claim_amount_reasonable(cls, v):
        """Ensure claim amount is within reasonable healthcare ranges"""
        if v > 50000:  # $50k max for demo scenarios
            raise ValueError('Claim amount exceeds maximum allowed for demo')
        return v

    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization"""
        return self.dict(by_alias=True)

    def is_high_priority(self) -> bool:
        """Check if claim requires expedited processing"""
        return self.priority in [ClaimPriority.URGENT, ClaimPriority.EMERGENCY]

    def get_estimated_processing_cost(self) -> float:
        """Calculate estimated AI processing cost for budget tracking"""
        # Base cost for OpenAI + NVIDIA APIs
        base_cost = 0.05
        
        # Additional cost for complex cases
        if self.medical_necessity_context and len(self.medical_necessity_context) > 500:
            base_cost += 0.02
            
        # Priority multiplier
        if self.priority == ClaimPriority.URGENT:
            base_cost *= 1.2
        elif self.priority == ClaimPriority.EMERGENCY:
            base_cost *= 1.5
            
        return round(base_cost, 3)


def generate_claim_id() -> str:
    """Create a valid claim ID with current timestamp"""
    date = datetime.now().strftime('%Y%m%d')
    sequence = f"{random.randint(0, 999):03d}"
    return f"CLAIM_{date}_{sequence}"


def validate_claim_id(claim_id: str) -> bool:
    """Validate claim ID format"""
    pattern = r"^CLAIM_\d{8}_\d{3}$"
    return bool(re.match(pattern, claim_id))