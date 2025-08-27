# Healthcare AI Governance Agent - Technology Stack

## Definitive Technology Selections

This document contains the **EXACT** technology versions and configurations that MUST be used throughout the Healthcare AI Governance Agent project. All AI development agents must reference this as the single source of truth.

## Frontend Stack

### **Core Framework**
- **React:** `18.2.0` (exact version for demonstration consistency)
- **TypeScript:** `5.2.2` (healthcare data type safety requirements)
- **Vite:** `4.4.9` (build tool optimized for development speed)

### **UI & Styling**
- **Tailwind CSS:** `3.3.3`
- **Headless UI:** `1.4.2` (accessible healthcare UI components)
- **Heroicons:** `2.0.18` (consistent icon library)

### **State Management**
- **React Query (TanStack Query):** `4.32.6` (server state management)
- **Zustand:** `4.4.1` (client state management)

### **Development Tools**
- **ESLint:** `8.47.0`
- **Prettier:** `3.0.2`
- **TypeScript ESLint:** `6.4.0`

## Backend Stack

### **Core Framework**
- **Python:** `3.11.5` (AWS Lambda optimized version)
- **FastAPI:** `0.103.1` (high-performance API framework)
- **Pydantic:** `2.3.0` (data validation and serialization)

### **AWS Services**
- **AWS Lambda:** Runtime `python3.11`
- **API Gateway:** REST API (not HTTP API for OpenAPI compatibility)
- **S3:** Standard storage class with Intelligent Tiering
- **DynamoDB:** On-demand billing mode
- **CloudWatch:** Standard log retention (7 days for cost control)
- **CloudFront:** Standard edge locations
- **Cognito:** User pools with JWT tokens

### **AI Integration**
- **OpenAI Python SDK:** `1.3.0`
- **NVIDIA AI Enterprise SDK:** (latest available at implementation)

### **Development & Testing**
- **pytest:** `7.4.2`
- **moto:** `4.2.5` (AWS service mocking)
- **black:** `23.7.0` (code formatting)
- **flake8:** `6.0.0` (linting)

## Infrastructure Stack

### **Infrastructure as Code**
- **Terraform:** `1.5.7` (exact version for state compatibility)
- **AWS Provider:** `5.17.0`

### **CI/CD**
- **GitHub Actions:** (built-in, no specific version)
- **AWS CLI:** `2.13.0` (for deployment scripts)

## Testing Stack

### **Frontend Testing**
- **Vitest:** `0.34.2` (Vite-native testing framework)
- **Testing Library React:** `13.4.0`
- **Testing Library Jest DOM:** `6.1.2`
- **MSW (Mock Service Worker):** `1.3.0` (API mocking)

### **Backend Testing**
- **pytest:** `7.4.2`
- **pytest-asyncio:** `0.21.1` (async testing support)
- **moto:** `4.2.5` (AWS service mocking)
- **httpx:** `0.24.1` (async HTTP client for testing)

### **End-to-End Testing**
- **Playwright:** `1.37.1` (cross-browser testing)
- **@playwright/test:** `1.37.1`

## Package Management

### **Frontend Package Management**
- **Node.js:** `18.17.1` (LTS version)
- **npm:** `9.8.1` (package manager)
- **npm workspaces:** (monorepo management)

### **Backend Package Management**
- **pip:** `23.2.1`
- **pip-tools:** `7.3.0` (dependency management)
- **requirements.txt** format for dependencies

## Development Environment

### **Required Tools**
- **Node.js:** `18.17.1`
- **Python:** `3.11.5`
- **Terraform:** `1.5.7`
- **AWS CLI:** `2.13.0`
- **Git:** `2.40.0+`

### **Recommended IDE Extensions**
- **TypeScript:** Built-in VS Code support
- **Python:** Official Python extension
- **Terraform:** HashiCorp Terraform extension
- **Prettier:** Code formatting
- **ESLint:** JavaScript/TypeScript linting

## API & External Services

### **OpenAI Configuration**
- **Model:** `gpt-4` (primary for medical reasoning)
- **Fallback Model:** `gpt-3.5-turbo` (cost optimization)
- **Max Tokens:** 1000 (healthcare response optimization)
- **Temperature:** 0.1 (consistent medical reasoning)

### **NVIDIA AI Enterprise**
- **Service:** NVIDIA AI Enterprise APIs
- **Authentication:** API key-based
- **Timeout:** 90 seconds (compliance validation processing)

### **AWS Service Configuration**
- **Region:** `us-east-1` (primary)
- **Lambda Memory:** 512MB (cost-optimized for AI API calls)
- **Lambda Timeout:** 900 seconds (15 minutes max)
- **DynamoDB:** Pay-per-request pricing

## Security & Compliance

### **Authentication**
- **JWT:** RS256 algorithm
- **Token Expiration:** 1 hour
- **Refresh Token:** 7 days (demo session duration)

### **Encryption**
- **In Transit:** TLS 1.3
- **At Rest:** AWS KMS default encryption
- **S3:** SSE-S3 encryption

## Monitoring & Observability

### **Logging**
- **Frontend:** Console logging (development) / Silent (production)
- **Backend:** Python `structlog` with JSON formatting
- **AWS:** CloudWatch log groups with 7-day retention

### **Metrics**
- **CloudWatch:** Custom metrics for cost tracking
- **API Gateway:** Request/response metrics enabled
- **Lambda:** Duration, memory, error rate monitoring

## Performance Targets

### **Frontend Performance**
- **Initial Load:** <3 seconds
- **Bundle Size:** <500KB gzipped
- **First Contentful Paint:** <1.5 seconds
- **Largest Contentful Paint:** <2.5 seconds

### **Backend Performance**
- **API Response Time:** <2 seconds (excluding AI processing)
- **Lambda Cold Start:** <1 second
- **Database Query Time:** <100ms (DynamoDB single-item reads)

### **AI Processing Performance**
- **OpenAI API Response:** <30 seconds
- **NVIDIA API Response:** <90 seconds
- **Total Claim Validation:** <2 minutes

## Cost Control Configuration

### **Budget Limits**
- **Per Demo Session:** $50 maximum
- **Daily Budget:** $200 maximum
- **Monthly Budget:** $1000 maximum

### **Cost Optimization Settings**
- **Lambda:** On-demand pricing with reserved concurrency limits
- **S3:** Lifecycle policies for auto-deletion after 7 days
- **DynamoDB:** TTL enabled for automatic item expiration
- **CloudWatch:** Log retention set to 7 days

## Version Control & Branching

### **Git Configuration**
- **Main Branch:** `main` (production deployments)
- **Feature Branches:** `feature/epic-1-claims-validator`
- **Hotfix Branches:** `hotfix/cost-control-fix`

### **Commit Message Format**
```
feat(claims): add OpenAI medical reasoning integration

- Implement GPT-4 medical necessity validation
- Add healthcare compliance prompt templates
- Include cost tracking for API usage

Refs: Epic 1 - Steel Thread Foundation
```

## Deployment Configuration

### **Environment Variables**
```bash
# Required for all environments
OPENAI_API_KEY=<user-provided>
NVIDIA_API_KEY=<user-provided>
AWS_REGION=us-east-1

# Environment-specific
NODE_ENV=development|staging|production
LOG_LEVEL=info|debug|error
DEMO_MODE=true|false
```

### **Deployment Targets**
- **Development:** Local development with mocked services
- **Staging:** AWS environment with reduced capacity
- **Production:** Full AWS deployment with monitoring

---

## Version Update Policy

**CRITICAL:** Technology versions in this document are LOCKED for project consistency. Any version changes require:

1. **Impact Assessment:** Analyze compatibility with existing code
2. **Testing:** Full regression testing in staging environment  
3. **Documentation Update:** Update this document with rationale
4. **Team Approval:** PO approval required for major version changes

**Exception:** Security patches may be applied without approval but must be documented.

---

*This technology stack ensures consistent, secure, and cost-controlled implementation of the Healthcare AI Governance Agent across all development phases.*