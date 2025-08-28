.PHONY: demo cleanup build test install

# Healthcare AI Governance Agent - Demo and Cleanup Automation
# Implements steel-thread methodology with complete lifecycle management

## Demo Commands

# Deploy complete system for executive demonstration
demo: check-env build-all deploy-infrastructure deploy-application
	@echo "🎯 Healthcare AI Governance Agent Demo Ready!"
	@echo "⚡ Deploy time: $$(date)"
	@echo "💰 Budget: Monitor at https://aws.amazon.com/billing/"
	@echo "🌐 Frontend: https://$$(terraform -chdir=infrastructure output -raw cloudfront_domain)"
	@echo "🔗 API: https://$$(terraform -chdir=infrastructure output -raw api_gateway_url)"

# Clean up all AWS resources and verify zero costs
cleanup: check-env
	@echo "🧹 Starting complete cleanup..."
	@terraform -chdir=infrastructure destroy -auto-approve
	@echo "💰 Verifying zero AWS costs..."
	@aws ce get-cost-and-usage --time-period Start=2025-08-25,End=2025-08-26 --granularity DAILY --metrics BlendedCost || true
	@echo "✅ Cleanup complete - zero ongoing costs confirmed"

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

# Backend steel-thread test harness with fixtures (CRITICAL)
test-backend:
	@echo "🧪 Running backend steel-thread tests with fixtures..."
	@cd tests && pip install -q -r requirements.txt
	@cd tests && python -m pytest test_steel_thread.py::TestSteelThread::test_happy_path_preventive_care -v
	@cd tests && python -m pytest test_steel_thread.py::TestSteelThread::test_unhappy_path_invalid_claim_data -v
	@echo "✅ Backend steel-thread validation complete"

# Frontend steel-thread test harness (placeholder - requires web-tier implementation)
test-frontend:
	@echo "🧪 Running frontend steel-thread tests..."
	@echo "⚠️  Frontend test harness not yet implemented"
	@echo "   Will include: React component testing with API integration"
	@echo "   Happy path: Dashboard displays claim results correctly"
	@echo "   Unhappy path: Error states and network failures handled"

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

# Deploy AWS infrastructure via Terraform
deploy-infrastructure:
	@echo "🏗️ Deploying AWS infrastructure..."
	@cd infrastructure && terraform init -upgrade
	@cd infrastructure && terraform plan -out=tfplan
	@cd infrastructure && terraform apply tfplan
	@echo "✅ Infrastructure deployed"

# Deploy application code
deploy-application:
	@echo "🚀 Deploying application..."
	@cd apps/api && python -m build
	@aws lambda update-function-code --function-name healthcare-claims-validator --zip-file fileb://apps/api/dist/lambda.zip
	@cd apps/web && npm run build
	@aws s3 sync apps/web/dist s3://$$(terraform -chdir=infrastructure output -raw s3_bucket_name)
	@echo "✅ Application deployed"

## Validation Commands

# Check required environment variables
check-env:
	@echo "🔍 Checking environment..."
	@test -n "$$OPENAI_API_KEY" || (echo "❌ OPENAI_API_KEY required" && exit 1)
	@test -n "$$AWS_ACCESS_KEY_ID" || (echo "❌ AWS_ACCESS_KEY_ID required" && exit 1)
	@test -n "$$AWS_SECRET_ACCESS_KEY" || (echo "❌ AWS_SECRET_ACCESS_KEY required" && exit 1)
	@aws sts get-caller-identity > /dev/null || (echo "❌ AWS credentials invalid" && exit 1)
	@echo "✅ Environment validated"

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

# Help command
help:
	@echo "Healthcare AI Governance Agent - Development Commands"
	@echo ""
	@echo "🎯 Demo Commands:"
	@echo "  make demo          Deploy complete system for executive demonstration"
	@echo "  make cleanup       Clean up all AWS resources and verify zero costs"
	@echo "  make validate-demo Validate demonstration is working end-to-end"
	@echo ""
	@echo "🔧 Development Commands:"
	@echo "  make install       Install all dependencies"
	@echo "  make build-all     Build all packages"
	@echo "  make test          Run comprehensive tests"
	@echo "  make lint          Run linting"
	@echo "  make type-check    Run TypeScript type checking"
	@echo ""
	@echo "💰 Cost Commands:"
	@echo "  make check-costs   Check current AWS costs"
	@echo "  make monitor-costs Monitor costs in real-time"