#!/bin/bash
set -e

cd "$(dirname "$0")/.."

ENV_DEPLOY_FILE=".env.deploy"
FRONTEND_ENV="../frontend/.env"
ROOT_ENV="../.env"

echo "==================================="
echo "Gemenie Labs - Backend Deployment"
echo "==================================="
echo ""

# Load from .env.deploy if it exists
if [ -f "$ENV_DEPLOY_FILE" ]; then
    echo "Loading configuration from $ENV_DEPLOY_FILE..."
    export $(grep -v '^#' "$ENV_DEPLOY_FILE" | grep -v '^$' | xargs)
fi

# Get region with default
DEFAULT_REGION="${AWS_REGION:-us-west-2}"
read -p "AWS Region [$DEFAULT_REGION]: " input_region
AWS_REGION="${input_region:-$DEFAULT_REGION}"

# Get stack name with default
DEFAULT_STACK="${STACK_NAME:-gemenielabs-contact}"
read -p "Stack Name [$DEFAULT_STACK]: " input_stack
STACK_NAME="${input_stack:-$DEFAULT_STACK}"

# Email configuration
echo ""
echo "--- Email Configuration (SES) ---"
echo "Both addresses must be verified in SES."
echo ""

DEFAULT_TO="${TO_EMAIL:-}"
read -p "To Email (receives messages) [$DEFAULT_TO]: " input_to
TO_EMAIL="${input_to:-$DEFAULT_TO}"

DEFAULT_FROM="${FROM_EMAIL:-}"
read -p "From Email (sender) [$DEFAULT_FROM]: " input_from
FROM_EMAIL="${input_from:-$DEFAULT_FROM}"

# Save configuration
cat > "$ENV_DEPLOY_FILE" << EOF
# Deployment configuration (auto-saved)
AWS_REGION=$AWS_REGION
STACK_NAME=$STACK_NAME
TO_EMAIL=$TO_EMAIL
FROM_EMAIL=$FROM_EMAIL
EOF
echo ""
echo "Configuration saved to $ENV_DEPLOY_FILE"

echo ""
echo "Using configuration:"
echo "  Region: $AWS_REGION"
echo "  Stack Name: $STACK_NAME"
echo "  To Email: $TO_EMAIL"
echo "  From Email: $FROM_EMAIL"
echo ""

# Create deployment bucket if needed
DEPLOY_BUCKET="sam-deploy-gemenielabs-${AWS_REGION}"
echo "==================================="
echo "Step 1: Setup Deployment Bucket"
echo "==================================="

if ! aws s3 ls "s3://${DEPLOY_BUCKET}" --region "$AWS_REGION" 2>/dev/null; then
    echo "Creating deployment bucket: ${DEPLOY_BUCKET}"
    aws s3 mb "s3://${DEPLOY_BUCKET}" --region "$AWS_REGION"
else
    echo "Deployment bucket exists: ${DEPLOY_BUCKET}"
fi

echo ""
echo "==================================="
echo "Step 2: Build SAM Application"
echo "==================================="
echo ""
sam build --template template.yaml

echo ""
echo "==================================="
echo "Step 3: Deploy Stack"
echo "==================================="
echo ""

sam deploy \
    --stack-name "$STACK_NAME" \
    --region "$AWS_REGION" \
    --s3-bucket "$DEPLOY_BUCKET" \
    --s3-prefix "$STACK_NAME" \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides ToEmail="$TO_EMAIL" FromEmail="$FROM_EMAIL" \
    --no-confirm-changeset \
    --no-fail-on-empty-changeset

echo ""
echo "==================================="
echo "Deployment Complete!"
echo "==================================="
echo ""

# Get stack outputs
API_URL=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$AWS_REGION" \
    --query 'Stacks[0].Outputs[?OutputKey==`ContactApiUrl`].OutputValue' \
    --output text 2>/dev/null || echo "")

echo "Contact API URL: $API_URL"
echo ""

# Update frontend .env
update_env_var() {
    local key=$1
    local value=$2
    local file=$3

    if [ -z "$value" ] || [ "$value" = "None" ]; then
        return
    fi

    if grep -q "^${key}=" "$file" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$file"
    else
        echo "${key}=${value}" >> "$file"
    fi
}

# Create/update frontend .env
if [ ! -f "$FRONTEND_ENV" ]; then
    cat > "$FRONTEND_ENV" << EOF
# Contact Form API
VITE_CONTACT_API_URL=$API_URL
EOF
    echo "Created frontend/.env"
else
    update_env_var "VITE_CONTACT_API_URL" "$API_URL" "$FRONTEND_ENV"
    echo "Updated frontend/.env"
fi

# Also update root .env for reference
if [ ! -f "$ROOT_ENV" ]; then
    cat > "$ROOT_ENV" << EOF
# Contact Form API
VITE_CONTACT_API_URL=$API_URL

# Backend Configuration
TO_EMAIL=$TO_EMAIL
FROM_EMAIL=$FROM_EMAIL
EOF
    echo "Created root .env"
else
    update_env_var "VITE_CONTACT_API_URL" "$API_URL" "$ROOT_ENV"
    echo "Updated root .env"
fi

echo ""
echo "Done! Run 'npm run build' to rebuild frontend with new API URL."
