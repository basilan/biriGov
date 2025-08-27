#!/bin/bash
# Healthcare AI Governance Agent - Deployment Script

set -e

case "$1" in
    "up"|"deploy")
        echo "🚀 Deploying Healthcare AI Governance infrastructure..."
        terraform apply -auto-approve
        echo "✅ Deployment complete!"
        terraform output
        ;;
    "down"|"destroy")
        echo "🗑️  Destroying Healthcare AI Governance infrastructure..."
        terraform destroy -auto-approve
        echo "✅ All resources destroyed!"
        ;;
    "plan")
        echo "📋 Planning infrastructure changes..."
        terraform plan
        ;;
    *)
        echo "Usage: $0 {up|deploy|down|destroy|plan}"
        echo "  up/deploy  - Deploy all infrastructure"
        echo "  down/destroy - Destroy all infrastructure" 
        echo "  plan       - Show planned changes"
        exit 1
        ;;
esac