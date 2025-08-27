"""
Healthcare AI Governance Agent - Backend Configuration
Environment variables and settings management with validation
"""

import os
from typing import Optional
from pydantic import BaseSettings, validator


class Settings(BaseSettings):
    """
    Application settings with environment variable validation
    Follows coding standards: access config objects, never process.env directly
    """
    
    # API Configuration
    APP_NAME: str = "Healthcare AI Governance Agent"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # AI Configuration - Mock Mode for Steel-Thread Phase 1
    USE_MOCK_AI: bool = False
    MOCK_AI_REALISTIC_DELAYS: bool = True
    
    # OpenAI Configuration
    OPENAI_API_KEY: Optional[str] = "sk-mock-key-for-development"
    OPENAI_MODEL: str = "gpt-4"
    OPENAI_FALLBACK_MODEL: str = "gpt-3.5-turbo" 
    OPENAI_MAX_TOKENS: int = 1000
    OPENAI_TEMPERATURE: float = 0.1
    
    # NVIDIA AI Enterprise Configuration
    NVIDIA_API_KEY: Optional[str] = None
    NVIDIA_API_BASE_URL: str = "https://api.nvcf.nvidia.com/v2"
    NVIDIA_COMPLIANCE_TIMEOUT: int = 90
    NVIDIA_MAX_RETRIES: int = 3
    
    # AWS Configuration
    AWS_REGION: str = "us-east-1"
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    
    # DynamoDB Configuration  
    DYNAMODB_CLAIMS_TABLE: str = "healthcare-claims"
    DYNAMODB_RESULTS_TABLE: str = "validation-results"
    DYNAMODB_SESSIONS_TABLE: str = "demonstration-sessions"
    
    # S3 Configuration
    S3_BUCKET_NAME: str = "healthcare-ai-governance-demo"
    S3_CLAIMS_PREFIX: str = "claims/"
    S3_RESULTS_PREFIX: str = "results/"
    S3_SESSIONS_PREFIX: str = "sessions/"
    
    # Cost Control Configuration
    MAX_DEMO_BUDGET_USD: float = 50.0
    BUDGET_WARNING_THRESHOLD_USD: float = 45.0
    COST_TRACKING_ENABLED: bool = True
    
    # Processing Limits
    MAX_PROCESSING_TIME_SECONDS: int = 300  # 5 minutes
    MAX_CLAIMS_PER_SESSION: int = 10
    
    # CORS Configuration
    CORS_ORIGINS: list = ["http://localhost:3000", "https://*.cloudfront.net"]
    CORS_ALLOW_CREDENTIALS: bool = True
    CORS_ALLOW_METHODS: list = ["GET", "POST", "PUT", "DELETE"]
    CORS_ALLOW_HEADERS: list = ["*"]
    
    # Logging Configuration
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"
    AUDIT_LOGGING_ENABLED: bool = True
    CLOUDWATCH_LOG_GROUP: str = "/aws/lambda/healthcare-claims-validator"
    
    class Config:
        """Pydantic settings configuration"""
        env_file = ".env"
        case_sensitive = True
    
    @validator('OPENAI_API_KEY')
    def validate_openai_key(cls, v, values):
        """Ensure OpenAI API key is provided and properly formatted (unless using mocks)"""
        use_mock = values.get('USE_MOCK_AI', False)
        if use_mock:
            return v or "sk-mock-key-for-development"
            
        if not v:
            raise ValueError('OPENAI_API_KEY is required when USE_MOCK_AI=False')
        if not v.startswith('sk-'):
            raise ValueError('OPENAI_API_KEY must start with sk-')
        if len(v) < 20:
            raise ValueError('OPENAI_API_KEY appears to be invalid')
        return v
    
    @validator('MAX_DEMO_BUDGET_USD')
    def validate_demo_budget(cls, v):
        """Ensure demo budget is within acceptable range"""
        if v <= 0 or v > 100:
            raise ValueError('Demo budget must be between $1 and $100')
        return v
    
    @validator('BUDGET_WARNING_THRESHOLD_USD')
    def validate_warning_threshold(cls, v, values):
        """Ensure warning threshold is less than max budget"""
        max_budget = values.get('MAX_DEMO_BUDGET_USD', 50.0)
        if v >= max_budget:
            raise ValueError('Warning threshold must be less than max budget')
        return v
    
    @validator('CORS_ORIGINS')
    def validate_cors_origins(cls, v):
        """Validate CORS origins format"""
        if isinstance(v, str):
            return [origin.strip() for origin in v.split(',')]
        return v
    
    @validator('LOG_LEVEL')
    def validate_log_level(cls, v):
        """Ensure log level is valid"""
        valid_levels = ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']
        if v.upper() not in valid_levels:
            raise ValueError(f'LOG_LEVEL must be one of {valid_levels}')
        return v.upper()

    def get_openai_config(self) -> dict:
        """Get OpenAI configuration for API calls"""
        return {
            "api_key": self.OPENAI_API_KEY,
            "model": self.OPENAI_MODEL,
            "max_tokens": self.OPENAI_MAX_TOKENS,
            "temperature": self.OPENAI_TEMPERATURE
        }
    
    def get_nvidia_config(self) -> dict:
        """Get NVIDIA AI Enterprise configuration"""
        return {
            "api_key": self.NVIDIA_API_KEY,
            "base_url": self.NVIDIA_API_BASE_URL,
            "timeout": self.NVIDIA_COMPLIANCE_TIMEOUT,
            "max_retries": self.NVIDIA_MAX_RETRIES
        }
    
    def get_aws_config(self) -> dict:
        """Get AWS service configuration"""
        config = {
            "region_name": self.AWS_REGION
        }
        if self.AWS_ACCESS_KEY_ID and self.AWS_SECRET_ACCESS_KEY:
            config.update({
                "aws_access_key_id": self.AWS_ACCESS_KEY_ID,
                "aws_secret_access_key": self.AWS_SECRET_ACCESS_KEY
            })
        return config
    
    def get_cost_control_config(self) -> dict:
        """Get cost control configuration for budget monitoring"""
        return {
            "max_budget": self.MAX_DEMO_BUDGET_USD,
            "warning_threshold": self.BUDGET_WARNING_THRESHOLD_USD,
            "tracking_enabled": self.COST_TRACKING_ENABLED
        }
    
    def is_development(self) -> bool:
        """Check if running in development mode"""
        return self.DEBUG or os.getenv('ENVIRONMENT', '').lower() in ['dev', 'development']
    
    def is_production(self) -> bool:
        """Check if running in production mode"""
        return os.getenv('ENVIRONMENT', '').lower() in ['prod', 'production']


# Global settings instance
_settings: Optional[Settings] = None


def get_settings() -> Settings:
    """
    Get global settings instance (singleton pattern)
    Ensures consistent configuration access across the application
    """
    global _settings
    if _settings is None:
        _settings = Settings()
    return _settings


def reload_settings() -> Settings:
    """
    Reload settings from environment (useful for testing)
    """
    global _settings
    _settings = None
    return get_settings()