# Healthcare AI Governance Agent - Project Structure

## Complete Project Source Tree

This document defines the **EXACT** directory structure and file organization for the Healthcare AI Governance Agent project. All AI development agents must follow this structure precisely.

## Root Level Structure

```
healthcare-ai-governance/
├── .github/                          # CI/CD workflows and GitHub configuration
│   ├── workflows/
│   │   ├── ci.yml                   # Continuous Integration pipeline
│   │   ├── deploy-staging.yml       # Staging deployment
│   │   └── deploy-production.yml    # Production deployment
│   └── ISSUE_TEMPLATE/
│       └── bug_report.md
├── .vscode/                         # VS Code workspace configuration
│   ├── settings.json
│   ├── extensions.json
│   └── launch.json
├── apps/                            # Application packages (frontend & backend)
│   ├── web/                         # React frontend application
│   └── api/                         # Python Lambda backend
├── packages/                        # Shared packages across applications
│   ├── shared/                      # Shared types, utilities, constants
│   ├── ui/                         # Shared UI components
│   └── config/                     # Shared configuration
├── infrastructure/                  # Terraform Infrastructure as Code
├── scripts/                        # Build, deployment, and utility scripts
├── docs/                           # Project documentation
├── e2e/                           # End-to-end tests
├── .env.example                   # Environment variables template
├── .gitignore                     # Git ignore rules
├── package.json                   # Root package.json for workspace
├── package-lock.json              # Lockfile for dependencies
├── README.md                      # Project overview and setup
├── tsconfig.json                  # Root TypeScript configuration
└── playwright.config.ts           # E2E testing configuration
```

## Frontend Application Structure (`apps/web/`)

```
apps/web/
├── public/                         # Static assets served directly
│   ├── favicon.ico
│   ├── logo-healthcare.svg
│   └── manifest.json
├── src/                           # Source code
│   ├── components/                # React components organized by feature
│   │   ├── common/               # Reusable UI components
│   │   │   ├── Button/
│   │   │   │   ├── Button.tsx
│   │   │   │   ├── Button.test.tsx
│   │   │   │   └── index.ts
│   │   │   ├── LoadingSpinner/
│   │   │   └── ErrorBoundary/
│   │   ├── claims/               # Claims validation components
│   │   │   ├── ClaimValidator/
│   │   │   │   ├── ClaimValidator.tsx
│   │   │   │   ├── ClaimValidator.test.tsx
│   │   │   │   ├── ClaimValidator.stories.tsx
│   │   │   │   └── index.ts
│   │   │   ├── ClaimForm/
│   │   │   ├── ValidationResults/
│   │   │   └── ProcessingProgress/
│   │   ├── dashboard/            # Executive dashboard components
│   │   │   ├── ExecutiveSummary/
│   │   │   ├── CostMetrics/
│   │   │   ├── PerformanceCharts/
│   │   │   └── BusinessMetrics/
│   │   └── demo/                # Demonstration session components
│   │       ├── DemoControls/
│   │       ├── SessionStatus/
│   │       └── CleanupManager/
│   ├── pages/                    # Page-level components (routing)
│   │   ├── HomePage/
│   │   │   ├── HomePage.tsx
│   │   │   ├── HomePage.test.tsx
│   │   │   └── index.ts
│   │   ├── DashboardPage/
│   │   ├── ClaimsPage/
│   │   └── NotFoundPage/
│   ├── hooks/                    # Custom React hooks
│   │   ├── useClaimsValidation.ts
│   │   ├── useClaimsValidation.test.ts
│   │   ├── useDemoSession.ts
│   │   ├── useAuth.ts
│   │   └── index.ts
│   ├── services/                 # API client services
│   │   ├── claimsService.ts
│   │   ├── claimsService.test.ts
│   │   ├── demoService.ts
│   │   ├── authService.ts
│   │   ├── apiClient.ts          # Base API client configuration
│   │   └── index.ts
│   ├── stores/                   # Zustand state stores
│   │   ├── claimsStore.ts
│   │   ├── claimsStore.test.ts
│   │   ├── demoStore.ts
│   │   ├── authStore.ts
│   │   └── index.ts
│   ├── styles/                   # Global styles and Tailwind config
│   │   ├── globals.css
│   │   ├── components.css
│   │   └── healthcare-theme.css
│   ├── utils/                    # Frontend utility functions
│   │   ├── formatters.ts         # Data formatting utilities
│   │   ├── formatters.test.ts
│   │   ├── validators.ts         # Client-side validation
│   │   ├── constants.ts          # Frontend constants
│   │   └── index.ts
│   ├── types/                    # Frontend-specific types
│   │   ├── api.ts               # API response types
│   │   ├── ui.ts                # UI component types
│   │   └── index.ts
│   ├── config/                   # Frontend configuration
│   │   ├── env.ts               # Environment variables
│   │   ├── api.ts               # API endpoints
│   │   └── routes.ts            # Route definitions
│   ├── App.tsx                   # Main application component
│   ├── App.test.tsx
│   ├── main.tsx                  # Application entry point
│   └── vite-env.d.ts            # Vite type definitions
├── __tests__/                    # Test utilities and setup
│   ├── setup.ts
│   ├── mocks/
│   │   ├── handlers.ts          # MSW API mocks
│   │   └── data.ts              # Mock data
│   └── utils/
│       └── test-utils.tsx       # Testing utilities
├── .env.local                    # Local environment variables
├── .eslintrc.js                 # ESLint configuration
├── .gitignore
├── index.html                   # HTML template
├── package.json                 # Frontend dependencies
├── tailwind.config.js           # Tailwind CSS configuration
├── tsconfig.json               # TypeScript configuration
├── tsconfig.node.json          # Node.js TypeScript config
└── vite.config.ts              # Vite build configuration
```

## Backend Application Structure (`apps/api/`)

```
apps/api/
├── src/                          # Python source code
│   ├── handlers/                # Lambda function handlers
│   │   ├── __init__.py
│   │   ├── claims_validator.py  # Main claims validation handler
│   │   ├── demo_manager.py      # Demo session management
│   │   ├── health_check.py      # System health endpoints
│   │   └── auth_handler.py      # Authentication handlers
│   ├── services/                # Business logic services
│   │   ├── __init__.py
│   │   ├── claims_service.py    # Claims validation business logic
│   │   ├── ai_service.py        # OpenAI/NVIDIA AI integration
│   │   ├── demo_service.py      # Demo session management
│   │   ├── cost_service.py      # Cost tracking and budget control
│   │   └── audit_service.py     # Healthcare audit logging
│   ├── models/                  # Data models and schemas
│   │   ├── __init__.py
│   │   ├── healthcare_claim.py  # Healthcare claim data model
│   │   ├── validation_result.py # AI validation result model
│   │   ├── demo_session.py      # Demo session model
│   │   └── api_responses.py     # API response schemas
│   ├── repositories/            # Data access layer
│   │   ├── __init__.py
│   │   ├── claims_repository.py # Claims data access
│   │   ├── results_repository.py # Validation results storage
│   │   └── session_repository.py # Demo session persistence
│   ├── utils/                   # Backend utility functions
│   │   ├── __init__.py
│   │   ├── decorators.py        # Common decorators (@handle_errors, @audit_trail)
│   │   ├── validators.py        # Data validation utilities
│   │   ├── formatters.py        # Response formatting
│   │   ├── cost_calculator.py   # Cost calculation utilities
│   │   └── healthcare_utils.py  # Healthcare-specific utilities
│   ├── config/                  # Backend configuration
│   │   ├── __init__.py
│   │   ├── settings.py          # Environment configuration
│   │   ├── aws_config.py        # AWS service configurations
│   │   ├── ai_config.py         # OpenAI/NVIDIA configuration
│   │   └── logging_config.py    # Structured logging setup
│   └── middleware/              # Request/response middleware
│       ├── __init__.py
│       ├── cors_middleware.py   # CORS handling
│       ├── auth_middleware.py   # JWT authentication
│       └── error_middleware.py  # Global error handling
├── tests/                       # Backend tests
│   ├── __init__.py
│   ├── conftest.py             # pytest configuration and fixtures
│   ├── handlers/               # Handler tests
│   │   ├── __init__.py
│   │   ├── test_claims_validator.py
│   │   ├── test_demo_manager.py
│   │   └── test_health_check.py
│   ├── services/               # Service tests
│   │   ├── __init__.py
│   │   ├── test_claims_service.py
│   │   ├── test_ai_service.py
│   │   └── test_cost_service.py
│   ├── repositories/           # Repository tests
│   ├── utils/                  # Utility tests
│   ├── integration/            # Integration tests
│   │   ├── __init__.py
│   │   ├── test_api_integration.py
│   │   └── test_ai_integration.py
│   └── fixtures/               # Test data and fixtures
│       ├── healthcare_claims.json
│       ├── validation_results.json
│       └── demo_sessions.json
├── requirements/               # Python dependencies
│   ├── base.txt               # Base dependencies
│   ├── development.txt        # Development dependencies
│   ├── testing.txt           # Testing dependencies
│   └── production.txt        # Production-only dependencies
├── .env                       # Environment variables
├── .gitignore
├── Dockerfile                # Container configuration (if needed)
├── pyproject.toml           # Python project configuration
├── pytest.ini              # pytest configuration
└── requirements.txt         # Main requirements file
```

## Shared Packages Structure

### **Shared Package (`packages/shared/`)**

```
packages/shared/
├── src/
│   ├── types/                  # Shared TypeScript/Python types
│   │   ├── healthcare-claim.ts # HealthcareClaim interface
│   │   ├── validation-result.ts # ValidationResult interface
│   │   ├── demo-session.ts     # DemonstrationSession interface
│   │   ├── api.ts             # API request/response types
│   │   └── index.ts
│   ├── constants/             # Shared constants
│   │   ├── healthcare.ts      # Medical codes, claim statuses
│   │   ├── api-endpoints.ts   # API endpoint constants
│   │   ├── cost-limits.ts     # Budget and cost constants
│   │   └── index.ts
│   ├── utils/                 # Cross-platform utilities
│   │   ├── validation.ts      # Shared validation functions
│   │   ├── formatters.ts      # Data formatting utilities
│   │   ├── cost-calculator.ts # Cost calculation logic
│   │   └── index.ts
│   └── test-data/            # Shared test data
│       ├── demo-claims.json   # Sample healthcare claims
│       ├── demo-sessions.json # Sample demo sessions
│       └── index.ts
├── dist/                     # Built package
├── package.json
├── tsconfig.json
└── README.md
```

### **UI Package (`packages/ui/`)**

```
packages/ui/
├── src/
│   ├── components/           # Shared UI components
│   │   ├── Button/
│   │   ├── Card/
│   │   ├── Modal/
│   │   ├── Toast/
│   │   └── index.ts
│   ├── styles/              # Shared styles
│   │   ├── globals.css
│   │   ├── components.css
│   │   └── healthcare-theme.css
│   └── types/               # UI-specific types
│       └── index.ts
├── package.json
├── tsconfig.json
└── tailwind.config.js
```

## Infrastructure Structure (`infrastructure/`)

```
infrastructure/
├── environments/            # Environment-specific configurations
│   ├── development/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   └── production/
├── modules/                 # Reusable Terraform modules
│   ├── lambda-function/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── s3-bucket/
│   ├── api-gateway/
│   ├── dynamodb-table/
│   └── cloudfront-distribution/
├── global/                  # Global infrastructure (IAM, Route53)
│   ├── iam.tf
│   ├── route53.tf
│   └── variables.tf
├── main.tf                 # Root Terraform configuration
├── variables.tf            # Global variables
├── outputs.tf             # Infrastructure outputs
├── terraform.tfvars.example # Example variables file
└── README.md              # Infrastructure documentation
```

## Scripts Directory (`scripts/`)

```
scripts/
├── build/                  # Build scripts
│   ├── build-frontend.sh
│   ├── build-backend.sh
│   └── build-all.sh
├── deploy/                 # Deployment scripts
│   ├── deploy-infrastructure.sh
│   ├── deploy-application.sh
│   └── cleanup-demo.sh
├── setup/                  # Setup scripts
│   ├── setup-development.sh
│   ├── install-dependencies.sh
│   └── configure-aws.sh
├── test/                   # Testing scripts
│   ├── run-unit-tests.sh
│   ├── run-integration-tests.sh
│   └── run-e2e-tests.sh
└── utils/                  # Utility scripts
    ├── generate-types.sh
    ├── check-costs.sh
    └── validate-config.sh
```

## End-to-End Tests (`e2e/`)

```
e2e/
├── tests/
│   ├── demo-workflow.spec.ts        # Complete demo session test
│   ├── claims-validation.spec.ts    # Claims processing workflow
│   ├── cost-tracking.spec.ts        # Budget compliance test
│   ├── auth-flow.spec.ts           # Authentication workflow
│   └── error-scenarios.spec.ts     # Error handling tests
├── fixtures/                       # Test data and fixtures
│   ├── demo-claims.json
│   ├── expected-results.json
│   └── test-users.json
├── page-objects/                   # Page object models
│   ├── HomePage.ts
│   ├── DashboardPage.ts
│   └── ClaimsPage.ts
├── utils/                         # Test utilities
│   ├── test-helpers.ts
│   └── mock-apis.ts
└── playwright.config.ts           # Playwright configuration
```

## Documentation Structure (`docs/`)

```
docs/
├── architecture/           # Architecture documentation
│   ├── coding-standards.md
│   ├── tech-stack.md
│   └── source-tree.md
├── stories/               # User stories and epics
│   ├── epic-1-foundation.md
│   ├── story-claims-validator.md
│   └── story-demo-interface.md
├── api/                   # API documentation
│   ├── openapi.yml
│   └── authentication.md
├── deployment/            # Deployment guides
│   ├── local-development.md
│   ├── staging-deployment.md
│   └── production-deployment.md
├── guides/               # User and developer guides
│   ├── getting-started.md
│   ├── development-workflow.md
│   └── troubleshooting.md
├── architecture.md       # Main architecture document
├── prd.md                # Product Requirements Document
├── brief.md              # Project brief
└── ux-wireframes.md      # UI/UX specifications
```

## File Naming Conventions

### **TypeScript/JavaScript Files**
- **Components:** PascalCase (`ClaimValidator.tsx`)
- **Hooks:** camelCase with `use` prefix (`useClaimsValidation.ts`)
- **Services:** camelCase with `Service` suffix (`claimsService.ts`)
- **Utilities:** camelCase (`formatHealthcareData.ts`)
- **Types:** kebab-case (`healthcare-claim.ts`)

### **Python Files**
- **Modules:** snake_case (`claims_validator.py`)
- **Classes:** PascalCase in snake_case files (`class ClaimsValidator`)
- **Functions:** snake_case (`validate_healthcare_claim`)
- **Constants:** SCREAMING_SNAKE_CASE (`OPENAI_MODEL_NAME`)

### **Configuration Files**
- **Environment:** `.env`, `.env.local`, `.env.example`
- **Config:** lowercase with descriptive names (`tailwind.config.js`)
- **Infrastructure:** descriptive names (`main.tf`, `variables.tf`)

## Import Path Conventions

### **Frontend Imports**
```typescript
// External dependencies
import React from 'react'
import { useQuery } from '@tanstack/react-query'

// Shared packages
import { HealthcareClaim } from '@shared/types'
import { Button } from '@ui/components'

// Local imports (relative)
import { ClaimValidator } from '../components'
import { useClaimsValidation } from '../hooks'
```

### **Backend Imports**
```python
# Standard library
import json
import logging
from datetime import datetime

# Third-party packages
from fastapi import FastAPI, HTTPException
import boto3

# Local imports
from src.models.healthcare_claim import HealthcareClaim
from src.services.ai_service import AIService
from src.utils.decorators import handle_errors
```

## Development Workflow File Organization

### **Feature Branch Structure**
When working on features, organize temporary files:
```
feature/epic-1-claims-validator/
├── WIP-component-changes/
├── test-data/
├── design-mockups/
└── implementation-notes.md
```

### **Documentation During Development**
```
.ai/                           # AI development artifacts
├── debug-log.md              # Development debug log
├── implementation-notes.md    # Implementation decisions
└── test-scenarios.md         # Testing scenarios
```

---

## Critical Notes for AI Development Agents

1. **Always Create Directory Structure First:** Before implementing any feature, ensure the target directories exist
2. **Follow Exact File Naming:** Deviations from naming conventions will break imports and build processes
3. **Respect Package Boundaries:** Never import directly between apps - use shared packages
4. **Maintain Test Co-location:** Test files must be adjacent to source files or in designated test directories
5. **Update Index Files:** Always update index.ts files when adding new modules
6. **Document Structure Changes:** Any additions to this structure must be documented and approved

*This source tree structure ensures consistent, maintainable, and scalable organization of the Healthcare AI Governance Agent codebase.*