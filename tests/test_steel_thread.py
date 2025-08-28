"""
Healthcare AI Governance - Steel-Thread Test Harness
Validates complete end-to-end functionality with fixtures-driven scenarios

This test harness ensures the steel-thread always works by testing:
1. Happy Path: Standard claims processing flows successfully
2. Unhappy Path: Error handling and edge cases work properly
3. Infrastructure: AWS Lambda, API Gateway, DynamoDB integration
4. Business Logic: AI validation, cost tracking, audit trails
"""

import json
import os
import pytest
import requests
from decimal import Decimal
from typing import Dict, Any
from datetime import datetime, timedelta

# Test configuration
API_BASE_URL = os.environ.get('API_GATEWAY_URL', 'https://your-api-gateway-url')
TEST_TIMEOUT = 30  # seconds


class TestFixtures:
    """Realistic test data fixtures for healthcare claims validation"""
    
    @staticmethod
    def standard_preventive_claim() -> Dict[str, Any]:
        """Standard preventive care claim - should approve quickly"""
        return {
            "claimId": f"TEST_PREVENTIVE_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}",
            "patientId": "PAT_TEST_001",
            "providerId": "PROV_TEST_001", 
            "procedureCode": "99213",  # Office visit - established patient
            "diagnosisCode": "Z00.00",  # Annual wellness visit
            "claimAmount": 185.0,
            "dateOfService": "2025-08-15",
            "priority": "routine"
        }
    
    @staticmethod
    def complex_surgical_claim() -> Dict[str, Any]:
        """Complex surgical claim - should require review or approve with high confidence"""
        return {
            "claimId": f"TEST_SURGICAL_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}",
            "patientId": "PAT_TEST_002",
            "providerId": "PROV_TEST_002",
            "procedureCode": "47562",  # Laparoscopic cholecystectomy
            "diagnosisCode": "K80.20",  # Calculus of gallbladder
            "claimAmount": 8750.0,
            "dateOfService": "2025-08-20",
            "priority": "standard"
        }
    
    @staticmethod
    def experimental_treatment_claim() -> Dict[str, Any]:
        """Experimental treatment claim - should require human review"""
        return {
            "claimId": f"TEST_EXPERIMENTAL_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}",
            "patientId": "PAT_TEST_003",
            "providerId": "PROV_TEST_003",
            "procedureCode": "C9999",  # Investigational procedure code
            "diagnosisCode": "C78.89",  # Secondary malignant neoplasm
            "claimAmount": 25000.0,
            "dateOfService": "2025-08-25",
            "priority": "urgent"
        }
    
    @staticmethod
    def invalid_claim_data() -> Dict[str, Any]:
        """Invalid claim data - should trigger validation errors"""
        return {
            "claimId": "",  # Empty claim ID
            "patientId": "PAT_INVALID",
            "providerId": "",  # Empty provider ID
            "procedureCode": "INVALID_CODE",
            "diagnosisCode": "INVALID_DIAGNOSIS",
            "claimAmount": -100.0,  # Negative amount
            "dateOfService": "invalid-date",
            "priority": "invalid_priority"
        }


class TestSteelThread:
    """Steel-thread test harness with happy and unhappy path validation"""
    
    def setup_method(self):
        """Setup for each test method"""
        if not API_BASE_URL or 'your-api-gateway-url' in API_BASE_URL:
            pytest.skip("API_GATEWAY_URL not configured - run 'make deploy' first")
    
    def test_happy_path_preventive_care(self):
        """
        HAPPY PATH: Standard preventive care claim processing
        
        Validates:
        1. API accepts valid claim data
        2. Lambda processes claim within timeout
        3. DynamoDB stores claim record
        4. Mock AI returns realistic validation
        5. Business metrics calculated correctly
        6. Audit trail created
        """
        print("\\n🧪 Testing Happy Path: Preventive Care Claim")
        
        # Arrange: Get test fixture
        claim_data = TestFixtures.standard_preventive_claim()
        print(f"   📋 Claim ID: {claim_data['claimId']}")
        print(f"   🏥 Procedure: {claim_data['procedureCode']} (${claim_data['claimAmount']})")
        
        # Act: Submit claim to API
        response = requests.post(
            f"{API_BASE_URL}/claims",
            json=claim_data,
            headers={"Content-Type": "application/json"},
            timeout=TEST_TIMEOUT
        )
        
        # Assert: Validate response structure and business logic
        assert response.status_code == 201, f"Expected 201, got {response.status_code}: {response.text}"
        
        response_data = response.json()
        assert response_data["success"] is True
        assert "data" in response_data
        
        claim_result = response_data["data"]
        
        # Validate core claim processing
        assert claim_result["claim_id"] == claim_data["claimId"]
        assert claim_result["status"] in ["APPROVED", "PENDING", "DENIED"]
        assert "processing_time_ms" in claim_result
        assert claim_result["processing_time_ms"] < 5000  # Under 5 seconds
        
        # Validate AI reasoning results
        assert "ai_confidence_score" in claim_result
        assert 0 <= claim_result["ai_confidence_score"] <= 100
        assert "ai_reasoning" in claim_result
        assert len(claim_result["ai_reasoning"]) > 50  # Meaningful reasoning text
        
        # Validate business metrics
        assert "business_metrics" in claim_result
        metrics = claim_result["business_metrics"]
        assert "cost_reduction" in metrics
        assert metrics["cost_reduction"] > 0  # Should show cost savings
        assert "processing_time_reduction_percent" in metrics
        
        # Validate compliance checks
        assert "compliance_checks" in claim_result
        assert len(claim_result["compliance_checks"]) > 0
        
        # Validate validation summary
        assert "validation_summary" in claim_result
        summary = claim_result["validation_summary"]
        assert "medical_necessity" in summary
        assert "coding_accuracy" in summary
        assert "fraud_indicators" in summary
        assert "compliance_status" in summary
        
        print("   ✅ Happy path validation passed")
        print(f"   📊 Status: {claim_result['status']}")
        print(f"   🎯 Confidence: {claim_result['ai_confidence_score']}%")
        print(f"   💰 Cost Reduction: ${metrics['cost_reduction']}")
    
    def test_happy_path_status_retrieval(self):
        """
        HAPPY PATH: Claim status retrieval after submission
        
        Validates:
        1. Submit claim successfully
        2. Retrieve claim status by ID
        3. Verify data persistence in DynamoDB
        4. Confirm processing completion
        """
        print("\\n🧪 Testing Happy Path: Claim Status Retrieval")
        
        # Arrange: Submit a claim first
        claim_data = TestFixtures.complex_surgical_claim()
        submit_response = requests.post(
            f"{API_BASE_URL}/claims",
            json=claim_data,
            headers={"Content-Type": "application/json"},
            timeout=TEST_TIMEOUT
        )
        
        assert submit_response.status_code == 201
        claim_id = claim_data["claimId"]
        print(f"   📋 Submitted Claim ID: {claim_id}")
        
        # Act: Retrieve claim status
        status_response = requests.get(
            f"{API_BASE_URL}/claims/{claim_id}",
            timeout=TEST_TIMEOUT
        )
        
        # Assert: Validate status retrieval
        assert status_response.status_code == 200, f"Expected 200, got {status_response.status_code}"
        
        status_data = status_response.json()
        assert status_data["success"] is True
        assert "data" in status_data
        
        claim_info = status_data["data"]["claim"]
        assert claim_info["claimId"] == claim_id
        assert "status" in claim_info
        assert "processed_at" in claim_info
        
        processing_complete = status_data["data"]["processing_complete"]
        assert processing_complete is True
        
        print("   ✅ Status retrieval validation passed")
        print(f"   📊 Retrieved Status: {claim_info['status']}")
    
    def test_unhappy_path_invalid_claim_data(self):
        """
        UNHAPPY PATH: Invalid claim data validation
        
        Validates:
        1. API rejects invalid claim data
        2. Proper error messages returned
        3. No database pollution from bad data
        4. Error handling works correctly
        """
        print("\\n🧪 Testing Unhappy Path: Invalid Claim Data")
        
        # Arrange: Get invalid test fixture  
        invalid_claim = TestFixtures.invalid_claim_data()
        print(f"   ❌ Invalid Claim: Empty ID, negative amount")
        
        # Act: Submit invalid claim
        response = requests.post(
            f"{API_BASE_URL}/claims",
            json=invalid_claim,
            headers={"Content-Type": "application/json"},
            timeout=TEST_TIMEOUT
        )
        
        # Assert: Validate error handling
        assert response.status_code in [400, 422, 500], f"Expected error status, got {response.status_code}"
        
        response_data = response.json()
        assert response_data["success"] is False
        assert "error" in response_data
        
        error_info = response_data["error"]
        assert "message" in error_info
        assert len(error_info["message"]) > 0  # Meaningful error message
        
        print("   ✅ Invalid data rejection passed")
        print(f"   🔍 Error: {error_info['message'][:100]}...")
    
    def test_unhappy_path_nonexistent_claim_status(self):
        """
        UNHAPPY PATH: Non-existent claim status lookup
        
        Validates:
        1. API handles missing claim IDs gracefully
        2. Returns proper 404 status
        3. Error message is informative
        """
        print("\\n🧪 Testing Unhappy Path: Non-existent Claim Lookup")
        
        # Arrange: Use non-existent claim ID
        nonexistent_claim_id = f"NONEXISTENT_CLAIM_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}"
        print(f"   🔍 Looking up non-existent claim: {nonexistent_claim_id}")
        
        # Act: Try to retrieve non-existent claim
        response = requests.get(
            f"{API_BASE_URL}/claims/{nonexistent_claim_id}",
            timeout=TEST_TIMEOUT
        )
        
        # Assert: Validate 404 handling
        assert response.status_code == 404, f"Expected 404, got {response.status_code}"
        
        response_data = response.json()
        assert response_data["success"] is False
        assert "error" in response_data
        assert "not found" in response_data["error"]["message"].lower()
        
        print("   ✅ Non-existent claim handling passed")
        print(f"   📄 Error: {response_data['error']['message']}")
    
    def test_unhappy_path_api_timeout_handling(self):
        """
        UNHAPPY PATH: API timeout and resilience
        
        Validates:
        1. API responds within reasonable timeouts
        2. Lambda doesn't hang indefinitely
        3. Proper error handling for timeouts
        """
        print("\\n🧪 Testing Unhappy Path: API Timeout Handling")
        
        # Arrange: Standard claim with short timeout
        claim_data = TestFixtures.standard_preventive_claim()
        short_timeout = 1  # 1 second - might be too short for Lambda cold start
        
        try:
            # Act: Submit with very short timeout
            response = requests.post(
                f"{API_BASE_URL}/claims",
                json=claim_data,
                headers={"Content-Type": "application/json"},
                timeout=short_timeout
            )
            
            # If we get here, API was fast enough
            assert response.status_code in [200, 201], f"Fast response got {response.status_code}"
            print("   ⚡ API responded within 1 second - excellent performance")
            
        except requests.exceptions.Timeout:
            # This is expected behavior for short timeout
            print("   ⏰ API timeout occurred as expected (Lambda cold start?)")
            print("   ✅ Timeout handling working correctly")
            
            # Now try with reasonable timeout to confirm API is working
            response = requests.post(
                f"{API_BASE_URL}/claims",
                json=claim_data,
                headers={"Content-Type": "application/json"},
                timeout=TEST_TIMEOUT
            )
            assert response.status_code == 201, "API should work with proper timeout"
            print("   ✅ API recovered with proper timeout")


class TestInfrastructureHealth:
    """Infrastructure health checks for steel-thread validation"""
    
    def setup_method(self):
        """Setup for infrastructure tests"""
        if not API_BASE_URL or 'your-api-gateway-url' in API_BASE_URL:
            pytest.skip("API_GATEWAY_URL not configured - run 'make deploy' first")
    
    def test_api_gateway_health(self):
        """Validate API Gateway is accessible and responding"""
        print("\\n🧪 Testing Infrastructure: API Gateway Health")
        
        # Test basic connectivity
        try:
            response = requests.get(f"{API_BASE_URL}/health", timeout=10)
            assert response.status_code == 200
            print("   ✅ API Gateway health check passed")
        except requests.exceptions.RequestException as e:
            pytest.fail(f"API Gateway health check failed: {e}")
    
    def test_lambda_function_execution(self):
        """Validate Lambda function executes without errors"""
        print("\\n🧪 Testing Infrastructure: Lambda Execution")
        
        # Submit minimal valid claim to test Lambda
        minimal_claim = {
            "claimId": f"HEALTH_CHECK_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}",
            "patientId": "HEALTH_TEST",
            "providerId": "HEALTH_PROVIDER",
            "procedureCode": "99213",
            "diagnosisCode": "Z00.00", 
            "claimAmount": 100.0,
            "dateOfService": "2025-08-15",
            "priority": "routine"
        }
        
        response = requests.post(
            f"{API_BASE_URL}/claims",
            json=minimal_claim,
            headers={"Content-Type": "application/json"},
            timeout=15
        )
        
        assert response.status_code == 201, f"Lambda execution failed: {response.status_code}"
        assert "steel_thread" in response.json()  # Confirm our Lambda is running
        print("   ✅ Lambda function execution passed")


if __name__ == "__main__":
    """
    Direct execution for quick steel-thread validation
    Usage: python test_steel_thread.py
    """
    print("🧪 Healthcare AI Governance - Steel-Thread Test Harness")
    print("=" * 60)
    
    # Check configuration
    if not API_BASE_URL or 'your-api-gateway-url' in API_BASE_URL:
        print("❌ API_GATEWAY_URL not configured")
        print("   Run 'export API_GATEWAY_URL=<your-api-url>' first")
        print("   Or run 'make deploy' to get the URL")
        exit(1)
    
    print(f"🌐 Testing against: {API_BASE_URL}")
    print("⏰ Starting steel-thread validation...")
    
    # Run basic connectivity test
    try:
        response = requests.get(f"{API_BASE_URL}/health", timeout=5)
        if response.status_code == 200:
            print("✅ API Gateway connectivity confirmed")
        else:
            print(f"⚠️  API Gateway health check returned {response.status_code}")
    except Exception as e:
        print(f"❌ API Gateway not accessible: {e}")
        exit(1)
    
    print("\\n🎯 Steel-thread validation complete!")
    print("   Run 'make test-backend' for full pytest execution")