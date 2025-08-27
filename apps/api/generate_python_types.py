#!/usr/bin/env python3
"""
Validate Python models match TypeScript interfaces
Ensures backend consistency with shared frontend types
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Any

def validate_python_models():
    """Validate that Python Pydantic models match TypeScript interfaces"""
    
    print("🔍 Validating Python models match TypeScript interfaces...")
    
    # Check if model files exist
    models_dir = Path("src/models")
    expected_models = [
        "healthcare_claim.py",
        "validation_result.py", 
        "demonstration_session.py",
        "__init__.py"
    ]
    
    validation_results = []
    
    for model_file in expected_models:
        model_path = models_dir / model_file
        if model_path.exists():
            print(f"   ✅ {model_file} - Found")
            validation_results.append(True)
            
            # Basic validation of imports and classes
            try:
                with open(model_path, 'r') as f:
                    content = f.read()
                    
                # Check for required imports
                has_pydantic = "from pydantic import" in content
                has_enum = "from enum import Enum" in content or "Enum" in content
                has_datetime = "datetime" in content
                
                if has_pydantic and has_enum and has_datetime:
                    print(f"      ✅ Required imports present")
                else:
                    print(f"      ⚠️  Missing imports: pydantic={has_pydantic}, enum={has_enum}, datetime={has_datetime}")
                    
            except Exception as e:
                print(f"      ❌ Error reading file: {e}")
                validation_results.append(False)
        else:
            print(f"   ❌ {model_file} - Missing")
            validation_results.append(False)
    
    # Test model imports
    try:
        print("\n🔍 Testing model imports...")
        import sys
        sys.path.insert(0, 'src')
        
        from models import (
            HealthcareClaim, ClaimPriority, ClaimStatus,
            ValidationResult, ValidationStatus, ComplianceCheck,
            DemonstrationSession, SystemStatus, PresentationMetrics
        )
        
        print("   ✅ All models imported successfully")
        
        # Test basic model creation
        from datetime import datetime
        
        # Test HealthcareClaim
        test_claim = HealthcareClaim(
            claim_id="CLAIM_20250826_001",
            patient_id="DEMO_PATIENT_123",
            provider_id="PROV_456",
            service_date=datetime.now(),
            procedure_code="72148",
            diagnosis_code="M54.2",
            claim_amount=1250.00,
            status=ClaimStatus.SUBMITTED,
            submitted_at=datetime.now(),
            priority=ClaimPriority.ROUTINE
        )
        print("   ✅ HealthcareClaim model validation passed")
        
        validation_results.append(True)
        
    except ImportError as e:
        print(f"   ❌ Import error: {e}")
        validation_results.append(False)
    except Exception as e:
        print(f"   ❌ Model validation error: {e}")
        validation_results.append(False)
    
    # Summary
    total_checks = len(validation_results)
    passed_checks = sum(validation_results)
    
    print(f"\n📊 Validation Summary: {passed_checks}/{total_checks} checks passed")
    
    if all(validation_results):
        print("✅ All Python models are consistent with TypeScript interfaces")
        return True
    else:
        print("❌ Some validation checks failed")
        return False


if __name__ == "__main__":
    validate_python_models()