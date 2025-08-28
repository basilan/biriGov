#!/bin/bash
# Build Lambda deployment package with Linux-compatible dependencies
# 
# SOLUTION: Uses pip with --platform linux_x86_64 to ensure compatibility with AWS Lambda runtime
# TESTED: Works for boto3 and standard Python packages without native extensions
# ALTERNATIVE: For complex packages with native extensions, use Docker with Amazon Linux base image
#
# Usage: ./build_lambda.sh
# Output: lambda-deployment.zip (ready for AWS Lambda deployment)

set -e

echo "🔧 Building Lambda deployment package for Linux x86_64..."

# Clean up previous build
rm -rf ./lambda-build
rm -f ./lambda-deployment.zip

# Create build directory
mkdir -p lambda-build

# Install dependencies with Linux platform (works for boto3)
echo "📦 Installing boto3 for Linux..."
pip install -r ../apps/api/requirements.txt -t lambda-build/ \
  --platform linux_x86_64 \
  --python-version 3.11 \
  --no-deps \
  --force-reinstall

# Install boto3 dependencies separately
pip install botocore jmespath s3transfer python-dateutil urllib3 six -t lambda-build/ \
  --platform linux_x86_64 \
  --python-version 3.11 \
  --no-deps \
  --force-reinstall

# Copy source code to build directory
echo "📁 Copying source code..."
cp -r ../apps/api/src/* lambda-build/

# Create deployment zip
echo "🗜️  Creating deployment zip..."
cd lambda-build
zip -r ../lambda-deployment.zip . -x "**/__pycache__/*" "**/*.pyc" "**/tests/*" > /dev/null
cd ..

# Cleanup build directory
rm -rf ./lambda-build

echo "✅ Lambda package built: lambda-deployment.zip"
echo "📦 Package size: $(du -sh lambda-deployment.zip | cut -f1)"