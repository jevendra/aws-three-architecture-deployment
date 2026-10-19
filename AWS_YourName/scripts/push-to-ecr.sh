#!/usr/bin/env bash
set -euo pipefail
# Creates ECR repositories and pushes the two images. Requires AWS CLI, Docker, IAM permissions.
: "${AWS_REGION:?Set AWS_REGION, e.g. ap-south-1}"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
aws ecr describe-repositories --repository-names flask-backend --region "$AWS_REGION" >/dev/null 2>&1 || aws ecr create-repository --repository-name flask-backend --region "$AWS_REGION"
aws ecr describe-repositories --repository-names express-frontend --region "$AWS_REGION" >/dev/null 2>&1 || aws ecr create-repository --repository-name express-frontend --region "$AWS_REGION"
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REGISTRY"
docker build -t flask-backend:latest app/backend
docker tag flask-backend:latest "$REGISTRY/flask-backend:latest"
docker push "$REGISTRY/flask-backend:latest"
docker build -t express-frontend:latest app/frontend
docker tag express-frontend:latest "$REGISTRY/express-frontend:latest"
docker push "$REGISTRY/express-frontend:latest"
echo "Pushed to $REGISTRY. Update ECS task definitions and services next."
