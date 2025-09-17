# Healthcare AI Governance Agent

> **Steel-Thread Implementation**: Healthcare AI Claims Validation system demonstrating 60% cost reduction through AI-powered automation. Executive presentation focus with complete deploy→demonstrate→cleanup lifecycle in <5 minutes, <$50 budget.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![TypeScript](https://img.shields.io/badge/TypeScript-4.9-blue)](https://www.typescriptlang.org/)
[![Python](https://img.shields.io/badge/Python-3.11-blue)](https://www.python.org/)
[![AWS](https://img.shields.io/badge/AWS-Lambda%20%7C%20S3%20%7C%20DynamoDB-orange)](https://aws.amazon.com/)

## 🎯 Project Overview

Healthcare AI Claims Validation system designed for **executive demonstrations** to C-suite healthcare stakeholders. Demonstrates 60% cost reduction through AI-powered automation using OpenAI GPT-4 and NVIDIA AI Enterprise for medical reasoning and compliance validation.

### Key Features

- **🏥 Healthcare-Focused**: Medical terminology, HIPAA-aware logging, industry-specific styling
- **🤖 Dual AI Integration**: OpenAI GPT-4 (medical reasoning) + NVIDIA AI Enterprise (compliance)
- **💰 Cost-Controlled**: <$50 budget with automated cleanup and real-time monitoring
- **⚡ Executive-Ready**: <5 minute deploy→demo→cleanup cycle
- **🧪 Steel-Thread Architecture**: Complete working system from Epic 1

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- Python 3.11+
- AWS CLI configured
- Terraform installed

### Environment Setup

```bash
# Required API keys
export OPENAI_API_KEY="your-openai-key"
export NVIDIA_API_KEY="your-nvidia-key"
export AWS_REGION="us-east-1"
```

### Installation & Demo

```bash
# Clone and install
git clone https://github.com/basilan/birigov.git
cd birigov
npm install

# Complete demo lifecycle
make demo                # Deploy infrastructure + application
make validate-demo       # Verify end-to-end functionality
make cleanup            # Destroy all resources (cost control)
```

### Development Mode

```bash
# Start development servers
npm run dev              # Both frontend and backend
npm run dev:web          # Frontend only (Vite dev server)
npm run dev:api          # Backend only (Python development)

# Quality checks
npm run test             # Run all tests
npm run lint             # Lint all workspaces  
npm run type-check       # TypeScript type checking
```

## 🏗️ Architecture

### Technology Stack

- **Backend**: Python 3.11, AWS Lambda, FastAPI
- **Frontend**: React 18, TypeScript, Vite, Tailwind CSS
- **Infrastructure**: Terraform, AWS (Lambda, S3, DynamoDB, API Gateway)
- **AI Integration**: OpenAI GPT-4, NVIDIA AI Enterprise
- **Testing**: pytest (backend), Vitest (frontend), 85% coverage requirement

### Project Structure

```
healthcare-ai-governance/
├── apps/
│   ├── api/              # Python Lambda backend
│   │   ├── src/
│   │   │   ├── handlers/     # Lambda function handlers
│   │   │   ├── services/     # AI integration services
│   │   │   ├── models/       # Data models
│   │   │   └── utils/        # Utilities
│   │   └── requirements.txt
│   └── web/              # React frontend
│       ├── src/
│       │   ├── components/   # React components
│       │   ├── pages/        # Application pages
│       │   └── services/     # API integration
│       └── package.json
├── packages/
│   └── shared/           # TypeScript/Python shared types
├── infrastructure/       # Terraform IaC modules
├── tests/               # Integration tests
├── docs/                # Architecture documentation
└── scripts/             # Build and deployment scripts
```

### AI Integration Architecture

**Two-Tier Validation System:**
1. **OpenAI GPT-4**: Medical reasoning and clinical necessity validation
2. **NVIDIA AI Enterprise**: Compliance checking and regulatory validation
3. **Cost Control**: Built-in budget monitoring with $50 demo limit
4. **Fallback Strategy**: Graceful degradation for executive presentations

## 🧪 Testing & Quality

### Test Harness (Steel-Thread Validation)

```bash
# Backend integration tests
make test-backend        # Run backend steel-thread tests
make test-frontend       # Run frontend steel-thread tests
make test-steel-thread   # Complete integration validation

# Individual test execution
cd apps/web && npm run test -- ClaimsValidation
cd apps/api && python -m pytest tests/test_claims_service.py::test_specific_function
```

### Quality Standards

- **85% Test Coverage**: Automated testing with validation
- **Type Safety**: Full TypeScript/Python type hints
- **Security**: Healthcare-aware logging, secure API key management
- **Performance**: <2 minute claims processing requirement

## 💰 Cost Control

### Budget Management

- **Demo Budget**: <$50 per session
- **Real-Time Monitoring**: AWS cost tracking with alerts at $35/$45
- **Automated Cleanup**: Terraform destroy prevents ongoing costs
- **Resource Lifecycle**: S3 auto-deletion after 7 days, DynamoDB TTL enabled

### Infrastructure Management

```bash
# Terraform operations
cd infrastructure
terraform init
terraform plan
terraform apply
terraform destroy        # Cost cleanup

# AWS deployment
make deploy-infrastructure  # Terraform deployment
make deploy-application     # Code deployment to Lambda/S3
make check-costs           # Monitor AWS spending
```

## 🏥 Healthcare Context

### Compliance & Security

- **HIPAA Awareness**: No PII in logs, structured audit trails
- **Medical Codes**: CPT, ICD-10 validation in shared constants
- **AWS Best Practices**: Least-privilege IAM, encryption at rest
- **Audit Trails**: CloudWatch logging for governance demonstration

### Executive Presentation

- **Target Audience**: C-suite healthcare executives
- **Demonstration Goal**: 60% cost reduction through AI automation
- **Interface Design**: Medical-grade aesthetics, screenshot-ready results
- **Business Metrics**: ROI calculations with compliance validation

## 📚 Documentation

### Development Guides

- [Architecture Overview](./docs/architecture.md)
- [Epic 1 Steel-Thread Foundation](./docs/stories/epic-1-steel-thread-foundation.md)
- [Project Requirements](./docs/prd.md)
- [UX Wireframes](./docs/ux-wireframes.md)

### Context Files

- [Universal Development Methodology](./CLAUDE_UNIVERSAL.md)
- [Healthcare AI Project Context](./CLAUDE_PROJECT.md)
- [Development Session Context](./CONTEXT.md)

## 🔧 Development Methodology

This project follows **Backend-First Steel-Thread** methodology:

1. **Backend Core First**: Lambda functions with AI integrations
2. **Minimal Frontend Harness**: UI components to exercise backend
3. **Vertical Steel-Thread**: End-to-end functionality at each step
4. **Iterative Widening**: Add features while maintaining working system

### Epic Structure

```
Epic 1: Foundation + Basic Validator + Complete Lifecycle ✅
Epic 2: Enhanced AI Capabilities (In Progress)
Epic 3: Professional Interface & Business Case
Epic 4: Production Optimization
```

## 🤝 Contributing

### Development Workflow

1. Ensure all environment variables are set
2. Run `npm install` to install dependencies
3. Use `make test-steel-thread` to validate changes
4. Maintain 85% test coverage
5. Follow healthcare compliance patterns

### Quality Gates

- All tests pass with 85% coverage
- TypeScript type checking passes
- Linting passes without warnings
- Steel-thread validation succeeds

## 📄 License

MIT License - see [LICENSE](./LICENSE) file for details.

## 🎯 Business Impact

**Demonstrated Value:**
- 60% cost reduction through AI automation
- <2 minute claims processing (vs 8-10 minutes manual)
- Real-time compliance validation
- Complete audit trail for governance

**Executive Presentation Ready:**
- Professional healthcare industry styling
- Screenshot-ready results and metrics
- Meaningful ROI calculations
- Industry-appropriate medical terminology

---

**🚀 Ready for executive demonstrations with complete deploy→demonstrate→cleanup lifecycle in <5 minutes, <$50 budget.**