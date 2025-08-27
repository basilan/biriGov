# Healthcare AI Governance Agent - Coding Standards

## Critical Fullstack Rules

These standards are MANDATORY for AI agent implementation to ensure consistency and prevent common mistakes:

### **Type Sharing**
- **Rule:** Always define types in `packages/shared/src/types/` and import from there
- **Frontend:** `import { HealthcareClaim } from '@shared/types'`  
- **Backend:** `from packages.shared.types import HealthcareClaim`
- **Rationale:** Prevents type drift between frontend and backend

### **API Calls**
- **Rule:** Never make direct HTTP calls - use the service layer
- **Frontend:** Use services in `apps/web/src/services/`
- **Example:** `await claimsService.submitClaim(claim)` not `fetch('/api/claims')`
- **Rationale:** Centralized error handling and request configuration

### **Environment Variables**
- **Rule:** Access only through config objects, never process.env directly
- **Frontend:** Use `apps/web/src/config/env.ts`
- **Backend:** Use `apps/api/src/config/settings.py`
- **Example:** `config.OPENAI_API_KEY` not `process.env.OPENAI_API_KEY`
- **Rationale:** Type safety and validation for critical healthcare API keys

### **Error Handling**
- **Rule:** All API routes must use the standard error handler
- **Backend:** Use `@handle_errors` decorator on all Lambda handlers
- **Frontend:** Use `ApiError` interface for all error responses
- **Rationale:** Consistent healthcare audit trail and compliance logging

### **State Updates**
- **Rule:** Never mutate state directly - use proper state management patterns
- **Frontend:** Use Zustand actions: `claimsStore.updateStatus(id, status)`
- **Backend:** Use immutable data patterns in Lambda functions
- **Rationale:** Predictable state management for healthcare data integrity

## Healthcare-Specific Standards

### **Medical Data Handling**
- **HIPAA Compliance:** No patient identifiers in logs or error messages
- **Data Validation:** All medical codes (CPT, ICD-10) validated before processing
- **Audit Trail:** Every data operation logged with timestamps and user context

### **AI Integration Standards**
- **OpenAI API:** Always include healthcare context in prompts
- **NVIDIA API:** Use enterprise compliance functions with proper error handling
- **Response Caching:** Cache AI responses for demonstration consistency
- **Cost Tracking:** Log all external API calls with cost estimates

## File Organization Standards

### **Import Order**
```typescript
// 1. Node modules
import React from 'react'
import { FastAPI } from 'fastapi'

// 2. Shared packages  
import { HealthcareClaim } from '@shared/types'

// 3. Local imports (relative)
import { ClaimsService } from './services'
```

### **Component Structure**
```typescript
// apps/web/src/components/claims/ClaimValidator.tsx
interface ClaimValidatorProps {
  // Props interface first
}

export const ClaimValidator: React.FC<ClaimValidatorProps> = ({
  // Component implementation
}) => {
  // Hooks first
  // State declarations
  // Effect hooks
  // Event handlers
  // Render
}
```

### **Lambda Function Structure**
```python
# apps/api/src/handlers/claims_validator.py
@handle_errors
@log_execution_time
async def lambda_handler(event: dict, context: LambdaContext) -> dict:
    """
    Process healthcare claim validation request.
    
    Args:
        event: API Gateway event with claim data
        context: Lambda execution context
        
    Returns:
        Standardized API response with validation results
    """
    # Input validation first
    # Business logic
    # External API calls
    # Response formatting
```

## Naming Conventions

| Element | Frontend | Backend | Example |
|---------|----------|---------|---------|
| Components | PascalCase | - | `ClaimValidator.tsx` |
| Hooks | camelCase with 'use' | - | `useClaimsValidation.ts` |
| Services | camelCase + Service | - | `claimsService.ts` |
| API Routes | - | kebab-case | `/api/claims-validation` |
| Lambda Functions | - | snake_case | `claims_validator.py` |
| Database Tables | - | snake_case | `validation_results` |
| Constants | SCREAMING_SNAKE_CASE | SCREAMING_SNAKE_CASE | `OPENAI_MODEL_NAME` |

## Testing Standards

### **Test File Organization**
- **Frontend:** `__tests__/ComponentName.test.tsx`
- **Backend:** `tests/test_handler_name.py`
- **Integration:** `e2e/demo-workflow.spec.ts`

### **Test Naming**
```typescript
describe('ClaimValidator Component', () => {
  it('should validate claim with medical necessity context', () => {
    // Test implementation
  })
  
  it('should handle OpenAI API failure gracefully', () => {
    // Error scenario testing
  })
})
```

### **Mock Data Standards**
- Use realistic healthcare data (de-identified)
- Store test data in `packages/shared/src/test-data/`
- Follow HIPAA guidelines even for test data

## Documentation Standards

### **Component Documentation**
```typescript
/**
 * Healthcare claim validation component for executive demonstrations.
 * 
 * Integrates with OpenAI GPT-4 for medical reasoning and NVIDIA AI Enterprise
 * for compliance checking. Optimized for sub-2-minute processing cycles.
 * 
 * @example
 * <ClaimValidator
 *   claim={demoHealthcareClaim}
 *   onValidationComplete={handleResults}
 * />
 */
```

### **API Documentation**
- Use OpenAPI 3.0 specification (defined in architecture.md)
- Include request/response examples with realistic healthcare data
- Document error codes and healthcare compliance implications

## Security Standards

### **Healthcare Data Security**
- **Encryption:** All data encrypted in transit and at rest
- **Access Control:** Least privilege principle for all API calls
- **Audit Logging:** Every healthcare data operation logged to CloudWatch
- **API Keys:** Never commit API keys - use AWS Secrets Manager

### **Input Validation**
```typescript
// Frontend validation
const claimSchema = z.object({
  patientId: z.string().regex(/^DEMO_PATIENT_\d+$/),
  procedureCode: z.string().regex(/^\d{5}$/),
  diagnosisCode: z.string().regex(/^[A-Z]\d{2}\.\d$/),
})

// Backend validation
@validate_input(HealthcareClaimSchema)
async def process_claim(claim_data: dict):
```

## Performance Standards

### **Frontend Performance**
- **Bundle Size:** Target <500KB initial load
- **Loading States:** Always show progress for AI processing (2-minute cycles)
- **Error Boundaries:** Graceful degradation for demonstration reliability

### **Backend Performance** 
- **Lambda Cold Start:** Optimize imports to reduce startup time
- **API Response Time:** Target <2 seconds for claim validation
- **Cost Optimization:** Cache responses, optimize AI API usage

## Compliance & Audit Standards

### **Audit Trail Requirements**
```python
@audit_trail("CLAIM_VALIDATION")
async def validate_claim(claim: HealthcareClaim):
    logger.info("claim_validation_started", extra={
        "claim_id": claim.claim_id,
        "timestamp": datetime.utcnow().isoformat(),
        "user_id": get_current_user_id(),
        "cost_estimate": calculate_processing_cost(claim)
    })
```

### **Healthcare Compliance**
- **Data Retention:** Auto-expire demo data after 7 days (S3 lifecycle)
- **User Consent:** Executive demo users consent to data processing
- **Regulatory Alignment:** All AI decisions logged for regulatory demonstration

---

*These standards ensure consistent, secure, and compliant implementation of the Healthcare AI Governance Agent across all AI development agents.*