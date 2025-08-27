"""
Demonstration Session Models
Python equivalents of TypeScript interfaces from packages/shared/src/types/demo-session.ts
"""

from datetime import datetime
from enum import Enum
from typing import Optional
from pydantic import BaseModel, Field, validator
import re
import random


class SystemStatus(str, Enum):
    """System status for demonstration session tracking"""
    READY = "ready"
    PROCESSING = "processing"
    COMPLETE = "complete"
    ERROR = "error"


class PresentationMetrics(BaseModel):
    """Executive presentation metrics for stakeholder demonstrations"""
    
    cost_reduction_percentage: float = Field(
        ...,
        ge=0,
        le=100,
        description="Cost reduction percentage achieved (target: 60%)"
    )
    
    time_reduction_percentage: float = Field(
        ...,
        ge=0,
        le=100,
        description="Time reduction percentage vs manual process"
    )
    
    accuracy_improvement: float = Field(
        ...,
        ge=0,
        le=100,
        description="AI accuracy improvement over manual consistency"
    )
    
    compliance_score: float = Field(
        ...,
        ge=0,
        le=100,
        description="Overall compliance score (0-100)"
    )

    class Config:
        use_enum_values = True


class InfrastructureStatus(BaseModel):
    """AWS infrastructure status for system health monitoring"""
    
    aws_services_online: bool = Field(
        ...,
        description="All required AWS services operational"
    )
    
    openai_api_connected: bool = Field(
        ...,
        description="OpenAI API connectivity status"
    )
    
    nvidia_api_connected: bool = Field(
        ...,
        description="NVIDIA AI Enterprise API connectivity status"
    )
    
    last_health_check: datetime = Field(
        ...,
        description="Last successful health check timestamp"
    )

    class Config:
        use_enum_values = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


class DemonstrationSession(BaseModel):
    """
    Executive presentation session tracking for cost monitoring and 
    performance metrics during healthcare AI demonstrations
    """
    
    session_id: str = Field(
        ...,
        pattern=r"^DEMO_\d{8}_[A-Z0-9]+$",
        description="Unique demonstration session identifier (format: DEMO_YYYYMMDD_EXEC001)"
    )
    
    executive_user_id: str = Field(
        ...,
        min_length=1,
        description="Executive user identifier for session tracking"
    )
    
    started_at: datetime = Field(
        ...,
        description="Demo initiation timestamp"
    )
    
    completed_at: Optional[datetime] = Field(
        None,
        description="Demo completion timestamp - optional while running"
    )
    
    total_cost_usd: float = Field(
        ...,
        ge=0,
        le=50.0,
        description="Cumulative AWS + API costs in USD (must be < $50)"
    )
    
    claims_processed: int = Field(
        ...,
        ge=0,
        description="Total claims validated in this session"
    )
    
    avg_processing_time: float = Field(
        ...,
        gt=0,
        description="Average claim processing time in milliseconds"
    )
    
    system_status: SystemStatus = Field(
        ...,
        description="Overall system health status"
    )
    
    presentation_metrics: PresentationMetrics = Field(
        ...,
        description="Executive presentation metrics for stakeholder discussions"
    )
    
    infrastructure_status: InfrastructureStatus = Field(
        ...,
        description="Infrastructure health for system reliability"
    )

    class Config:
        use_enum_values = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }
        json_schema_extra = {
            "example": {
                "session_id": "DEMO_20250826_EXEC01",
                "executive_user_id": "john.doe@healthcarecorp.com",
                "started_at": "2025-08-26T09:00:00Z",
                "completed_at": None,
                "total_cost_usd": 12.45,
                "claims_processed": 25,
                "avg_processing_time": 2150.5,
                "system_status": "processing",
                "presentation_metrics": {
                    "cost_reduction_percentage": 62.5,
                    "time_reduction_percentage": 85.2,
                    "accuracy_improvement": 15.8,
                    "compliance_score": 94.2
                },
                "infrastructure_status": {
                    "aws_services_online": True,
                    "openai_api_connected": True,
                    "nvidia_api_connected": True,
                    "last_health_check": "2025-08-26T09:15:00Z"
                }
            }
        }

    @validator('total_cost_usd')
    def validate_cost_under_budget(cls, v):
        """Ensure demo cost stays under $50 budget limit"""
        if v > 50.0:
            raise ValueError('Demo cost cannot exceed $50 budget limit')
        return round(v, 2)

    @validator('started_at')
    def validate_started_at_not_future(cls, v):
        """Ensure start time is not in the future"""
        if v > datetime.utcnow():
            raise ValueError('Start time cannot be in the future')
        return v

    @validator('completed_at')
    def validate_completed_at_after_started(cls, v, values):
        """Ensure completion time is after start time"""
        if v is not None and 'started_at' in values:
            if v <= values['started_at']:
                raise ValueError('Completion time must be after start time')
        return v

    def to_dict(self) -> dict:
        """Convert to dictionary for JSON serialization"""
        return self.dict(by_alias=True)

    def is_running(self) -> bool:
        """Check if demonstration session is currently running"""
        return self.completed_at is None and self.system_status != SystemStatus.ERROR

    def is_completed(self) -> bool:
        """Check if demonstration session has completed successfully"""
        return self.completed_at is not None and self.system_status == SystemStatus.COMPLETE

    def get_session_duration_minutes(self) -> Optional[float]:
        """Get session duration in minutes"""
        if self.completed_at is None:
            # Return current duration if still running
            return (datetime.utcnow() - self.started_at).total_seconds() / 60.0
        return (self.completed_at - self.started_at).total_seconds() / 60.0

    def get_cost_per_claim(self) -> float:
        """Calculate cost per claim for efficiency metrics"""
        if self.claims_processed == 0:
            return 0.0
        return round(self.total_cost_usd / self.claims_processed, 3)

    def get_executive_dashboard_summary(self) -> dict:
        """Generate executive dashboard summary"""
        return {
            "session_id": self.session_id,
            "status": self.system_status.value.title(),
            "duration_minutes": round(self.get_session_duration_minutes() or 0, 1),
            "claims_processed": self.claims_processed,
            "total_cost": f"${self.total_cost_usd:.2f}",
            "cost_per_claim": f"${self.get_cost_per_claim():.3f}",
            "budget_remaining": f"${50.0 - self.total_cost_usd:.2f}",
            "cost_reduction": f"{self.presentation_metrics.cost_reduction_percentage:.1f}%",
            "time_savings": f"{self.presentation_metrics.time_reduction_percentage:.1f}%",
            "compliance_score": f"{self.presentation_metrics.compliance_score:.1f}%",
            "system_health": "Healthy" if all([
                self.infrastructure_status.aws_services_online,
                self.infrastructure_status.openai_api_connected,
                self.infrastructure_status.nvidia_api_connected
            ]) else "Issues Detected"
        }


def generate_session_id(executive_id: str) -> str:
    """Create a valid session ID with current timestamp and executive identifier"""
    date = datetime.now().strftime('%Y%m%d')
    exec_id = re.sub(r'[^A-Z0-9]', '', executive_id.upper())[:6]
    if not exec_id:
        exec_id = f"EXEC{random.randint(10, 99)}"
    return f"DEMO_{date}_{exec_id}"


def calculate_cost_reduction(manual_cost: float, ai_cost: float) -> float:
    """Calculate cost reduction percentage for executive presentation"""
    if manual_cost <= 0:
        return 0.0
    return round(((manual_cost - ai_cost) / manual_cost) * 100, 1)


def validate_demonstration_session(session_data: dict) -> bool:
    """Validate DemonstrationSession data structure"""
    try:
        DemonstrationSession(**session_data)
        return True
    except Exception:
        return False