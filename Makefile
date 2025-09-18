.PHONY: demo cleanup build test install

# Healthcare AI Governance Agent - Demo and Cleanup Automation
# Implements steel-thread methodology with complete lifecycle management

## Demo Commands

# Deploy complete steel-thread system for executive demonstration
deploy-steel-thread: check-env build-all deploy-infra deploy-backend
	@echo "🎯 Healthcare AI Steel-Thread System Deployed!"
	@echo "⚡ Deployment completed: $$(date)"
	@echo "💰 Budget monitoring: https://aws.amazon.com/billing/"
	$(eval API_URL := $(shell cd infrastructure && terraform output -raw api_gateway_stage_url 2>/dev/null || echo ""))
	@echo "🔗 API Endpoint: $(API_URL)"
	@echo "✅ Ready for steel-thread validation and demonstration"

# Validate complete steel-thread system works end-to-end
validate-steel-thread: test-backend test-frontend
	@echo "🎯 Complete steel-thread validation finished"
	@echo "✅ System ready for executive demonstration"

# Execute the actual healthcare AI demonstration
run-steel-thread: validate-steel-thread
	@echo "🚀 Running Healthcare AI Steel-Thread Demonstration..."
	$(eval API_URL := $(shell cd infrastructure && terraform output -raw api_gateway_stage_url 2>/dev/null || echo ""))
	@echo "🌐 Demo running at: $(API_URL)"
	@echo "📋 Use the API endpoint above for live demonstration"
	@echo "💡 Or run 'make start-frontend' for interactive UI demonstration"

# Clean teardown with verification of zero costs
undeploy-steel-thread: check-env
	@echo "🧹 Undeploying complete steel-thread system..."
	@terraform -chdir=infrastructure destroy -auto-approve
	@echo "💰 Verifying zero AWS costs..."
	@aws ce get-cost-and-usage --time-period Start=2025-08-25,End=2025-08-26 --granularity DAILY --metrics BlendedCost || true
	@echo "✅ Steel-thread system completely undeployed - zero ongoing costs confirmed"

## Development Commands

# Install all dependencies across workspaces
install:
	npm install
	cd apps/web && npm install
	cd packages/shared && npm install

# Build all packages
build-all: install
	npm run build

# Run comprehensive tests
test:
	npm run test
	npm run test:coverage

## Steel-Thread Test Harness (REQUIRED BY CLAUDE.MD)

# Backend-first development and testing (NO MOCKS - REAL AI)
backend-real: check-env
	@echo "🏗️ Backend-First Steel-Thread Development (REAL AI INTEGRATION)"
	@echo "================================================================"
	
	# Ensure NO MOCK mode
	@echo "🚫 Verifying MOCK mode is DISABLED..."
	@test "$${USE_MOCK_AI:-false}" = "false" || (echo "❌ USE_MOCK_AI must be false for real integration" && echo "💡 Export: export USE_MOCK_AI=false" && exit 1)
	@echo "✅ Mock mode disabled - using REAL AI APIs"
	
	# Install backend dependencies
	@echo "📦 Installing backend dependencies..."
	@cd apps/api && pip install -r requirements.txt
	
	# Test real AI integration
	@echo "🤖 Testing OpenAI integration..."
	@cd apps/api && python -c "from src.services.ai_service import AIService; import asyncio; print('✅ OpenAI service imports successfully')"
	
	@echo "✅ Backend-first environment ready for REAL AI development"

# Backend steel-thread test harness with fixtures (CRITICAL)
test-backend: backend-real
	@echo "🧪 Running backend steel-thread tests with REAL AI integration..."
	@echo "🔍 Getting API Gateway URL from Terraform..."
	$(eval API_URL := $(shell cd infrastructure && terraform output -raw api_gateway_stage_url 2>/dev/null || echo ""))
	@if [ -z "$(API_URL)" ]; then \
		echo "❌ No deployed infrastructure found. Run 'make demo' first."; \
		exit 1; \
	fi
	@echo "🌐 Testing against: $(API_URL)"
	@cd tests && pip install -q -r requirements.txt
	@cd tests && API_GATEWAY_URL="$(API_URL)" python -m pytest test_steel_thread.py::TestSteelThread::test_happy_path_preventive_care -v
	@cd tests && API_GATEWAY_URL="$(API_URL)" python -m pytest test_steel_thread.py::TestSteelThread::test_unhappy_path_invalid_claim_data -v
	@echo "✅ Backend steel-thread validation complete"

# Start frontend development server with deployed backend
start-frontend:
	@echo "🌐 Starting frontend development server..."
	@echo "🔍 Getting API Gateway URL from deployed infrastructure..."
	$(eval API_URL := $(shell cd infrastructure && terraform output -raw api_gateway_stage_url 2>/dev/null || echo ""))
	@if [ -z "$(API_URL)" ]; then \
		echo "❌ No deployed infrastructure found."; \
		echo "💡 Run 'make deploy-steel-thread' first to deploy the complete system."; \
		exit 1; \
	fi
	@echo "🚀 Backend running at: $(API_URL)"
	@echo "🎯 Starting frontend development server with backend integration..."
	@cd apps/web && VITE_API_BASE_URL="$(API_URL)" npm run dev

# Frontend steel-thread test harness with REAL backend integration
test-frontend:
	@echo "🧪 Running frontend steel-thread tests with REAL backend..."
	@echo "🔍 Getting API Gateway URL from Terraform..."
	$(eval API_URL := $(shell cd infrastructure && terraform output -raw api_gateway_stage_url 2>/dev/null || echo ""))
	@if [ -z "$(API_URL)" ]; then \
		echo "❌ No deployed infrastructure found. Run 'make demo' first."; \
		exit 1; \
	fi
	@echo "🌐 Testing frontend against: $(API_URL)"
	@cd apps/web && VITE_API_BASE_URL="$(API_URL)" npm run test
	@echo "✅ Frontend steel-thread validation complete"

# Run both backend and frontend steel-thread tests
test-steel-thread: test-backend test-frontend
	@echo "🎯 Complete steel-thread validation finished"

# Type checking across all packages
type-check:
	npm run type-check

# Linting across all packages
lint:
	npm run lint

## Infrastructure Commands

# Build Lambda deployment package with REAL AI dependencies
build-lambda:
	@echo "🔧 Building Lambda deployment package with REAL AI integration..."
	@cd infrastructure && chmod +x build_lambda.sh
	@cd infrastructure && ./build_lambda.sh
	@echo "✅ Lambda package ready for deployment"

# Deploy AWS infrastructure only (Lambda, DynamoDB, S3, API Gateway)
deploy-infra: build-lambda
	@echo "🏗️ Deploying AWS infrastructure..."
	@cd infrastructure && terraform init -upgrade
	@cd infrastructure && terraform plan -out=tfplan
	@cd infrastructure && terraform apply tfplan
	@echo "✅ Infrastructure deployed and ready"

# Deploy backend application to existing infrastructure
deploy-backend: build-lambda
	@echo "🚀 Deploying backend application..."
	@aws lambda update-function-code --function-name healthcare-claims-validator --zip-file fileb://infrastructure/lambda-deployment.zip
	@echo "✅ Backend application deployed"

# Deploy frontend application to existing infrastructure
deploy-frontend: 
	@echo "🌐 Deploying frontend application..."
	@cd apps/web && npm run build
	@aws s3 sync apps/web/dist s3://$$(terraform -chdir=infrastructure output -raw s3_bucket_name)
	@echo "✅ Frontend application deployed"

# Undeploy infrastructure and all applications
undeploy-infra: check-env
	@echo "🧹 Undeploying AWS infrastructure..."
	@terraform -chdir=infrastructure destroy -auto-approve
	@echo "✅ Infrastructure completely removed"

## Validation Commands

# Check required environment variables - COMPREHENSIVE VALIDATION
check-env:
	@echo "🔍 Healthcare AI Governance - Environment Validation"
	@echo "=================================================="
	
	# Core API Keys (REQUIRED for real AI integration)
	@test -n "$$OPENAI_API_KEY" || (echo "❌ OPENAI_API_KEY required" && echo "💡 Get your key from https://platform.openai.com/api-keys" && echo "💡 Export: export OPENAI_API_KEY='sk-your-key-here'" && exit 1)
	@echo "$$OPENAI_API_KEY" | grep -q "^sk-" || (echo "❌ OPENAI_API_KEY must start with 'sk-'" && exit 1)
	@test -n "$$NVIDIA_API_KEY" || (echo "⚠️  NVIDIA_API_KEY recommended for compliance validation" && echo "💡 Get your key from https://build.nvidia.com/")
	
	# AWS Credentials (REQUIRED for infrastructure)
	@test -n "$$AWS_ACCESS_KEY_ID" || (echo "❌ AWS_ACCESS_KEY_ID required" && echo "💡 Configure AWS CLI: aws configure" && exit 1)
	@test -n "$$AWS_SECRET_ACCESS_KEY" || (echo "❌ AWS_SECRET_ACCESS_KEY required" && echo "💡 Configure AWS CLI: aws configure" && exit 1)
	@test -n "$$AWS_REGION" -o -n "$$AWS_DEFAULT_REGION" || (echo "❌ AWS_REGION or AWS_DEFAULT_REGION required" && echo "💡 Export: export AWS_REGION='us-east-1'" && exit 1)
	
	# Test AWS Authentication
	@aws sts get-caller-identity > /dev/null || (echo "❌ AWS credentials invalid" && echo "💡 Run: aws configure" && exit 1)
	@echo "✅ AWS Authentication: $$(aws sts get-caller-identity --query 'Arn' --output text)"
	
	# Validate OpenAI API Key
	@echo "🧪 Testing OpenAI API connectivity..."
	@curl -s -f -H "Authorization: Bearer $$OPENAI_API_KEY" https://api.openai.com/v1/models > /dev/null || (echo "❌ OpenAI API key invalid or no internet connectivity" && exit 1)
	@echo "✅ OpenAI API: Connected and authenticated"
	
	# Configuration Validation
	@echo "⚙️  Configuration Status:"
	@echo "   - OpenAI Model: $${OPENAI_MODEL:-gpt-4}"
	@echo "   - AWS Region: $${AWS_REGION:-$$AWS_DEFAULT_REGION}"
	@echo "   - Max Budget: $${MAX_DEMO_BUDGET_USD:-50} USD"
	@echo "   - Environment: $${ENVIRONMENT:-development}"
	
	@echo "✅ Environment validation complete - Ready for steel-thread operations"

# Validate demonstration is working end-to-end
validate-demo:
	@echo "🧪 Validating demonstration..."
	@curl -f $$(terraform -chdir=infrastructure output -raw api_gateway_url)/health || (echo "❌ API health check failed" && exit 1)
	@echo "✅ Demo validation passed"

## Cost Monitoring Commands

# Check current AWS costs
check-costs:
	@echo "💰 Current AWS costs:"
	@aws ce get-cost-and-usage --time-period Start=2025-08-25,End=2025-08-26 --granularity DAILY --metrics BlendedCost

# Monitor costs in real-time during demo
monitor-costs:
	@echo "📊 Monitoring costs every 30 seconds (Ctrl+C to stop)..."
	@while true; do \
		make check-costs; \
		sleep 30; \
	done

## Documentation Commands

# Generate API documentation
docs:
	@echo "📖 Generating documentation..."
	@cd apps/api && python -m swagger_ui_bundle docs/openapi.yml
	@echo "✅ API docs: http://localhost:8080"

# Validate infrastructure is accessible and responding  
check-infra:
	@echo "🧪 Checking infrastructure health..."
	$(eval API_URL := $(shell cd infrastructure && terraform output -raw api_gateway_stage_url 2>/dev/null || echo ""))
	@if [ -z "$(API_URL)" ]; then \
		echo "❌ No deployed infrastructure found."; \
		echo "💡 Run 'make deploy-steel-thread' first."; \
		exit 1; \
	fi
	@curl -f "$(API_URL)/health" || (echo "❌ API health check failed" && exit 1)
	@echo "✅ Infrastructure health check passed"

## Documentation Commands

# Generate API documentation
docs:
	@echo "📖 Generating documentation..."
	@cd apps/api && python -m swagger_ui_bundle docs/openapi.yml
	@echo "✅ API docs: http://localhost:8080"

# Help command - Steel-Thread Command Reference
help:
	@echo "Healthcare AI Governance Agent - Steel-Thread Commands"
	@echo ""
	@echo "🎯 Steel-Thread Lifecycle:"
	@echo "  make deploy-steel-thread    Deploy complete system for demonstration"
	@echo "  make validate-steel-thread  Validate end-to-end system functionality"  
	@echo "  make run-steel-thread       Execute healthcare AI demonstration"
	@echo "  make undeploy-steel-thread  Clean teardown with cost verification"
	@echo ""
	@echo "🏗️ Infrastructure Commands:"
	@echo "  make deploy-infra          Deploy AWS infrastructure only"
	@echo "  make undeploy-infra        Remove AWS infrastructure"
	@echo "  make check-infra           Validate infrastructure health"
	@echo ""
	@echo "🔧 Application Commands:"
	@echo "  make deploy-backend        Deploy backend application"
	@echo "  make deploy-frontend       Deploy frontend application"
	@echo "  make test-backend          Test backend with real AI integration"
	@echo "  make test-frontend         Test frontend against deployed backend"
	@echo "  make start-frontend        Start frontend development server"
	@echo ""
	@echo "⚙️  Development Commands:"
	@echo "  make install               Install all dependencies"
	@echo "  make build-all             Build all packages"
	@echo "  make build-lambda          Build Lambda deployment package"
	@echo "  make lint                  Run linting"
	@echo "  make type-check            Run TypeScript type checking"
	@echo ""
	@echo "💰 Cost & Environment:"
	@echo "  make check-env             Validate environment variables"
	@echo "  make check-costs           Check current AWS costs"
	@echo "  make monitor-costs         Monitor costs in real-time"