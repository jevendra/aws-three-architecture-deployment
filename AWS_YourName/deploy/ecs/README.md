# ECS / ECR / VPC deployment runbook

## Build and push images
Both Dockerfiles are present in `app/backend` and `app/frontend`, include health checks, and run as non-root users. Test locally if Docker is installed:
```bash
docker compose up --build
# test http://localhost:3000 and both /health routes
docker compose down
```
Push images from the project root using AWS CLI v2, Docker, and an AWS identity with ECR permissions:
```bash
export AWS_REGION=ap-south-1
./scripts/push-to-ecr.sh
```

## Render and optionally register task definitions
Create/verify the ECS task execution role, VPC/subnets, security groups, and backend service discovery first. Set real values:
```bash
export AWS_REGION=ap-south-1
export ECS_TASK_EXECUTION_ROLE_ARN=arn:aws:iam::YOUR_ACCOUNT_ID:role/ecsTaskExecutionRole
export BACKEND_URL=http://flask-backend.internal:5000
export FRONTEND_ORIGIN=http://YOUR_ALB_DNS_NAME
./deploy/ecs/render-task-definitions.sh
# Review deploy/ecs/rendered/*.json; to register them:
REGISTER_TASKS=1 ./deploy/ecs/render-task-definitions.sh
```
The script discovers the account ID through `aws sts get-caller-identity`, substitutes values, validates the rendered JSON, creates CloudWatch log groups if missing, and can register both task definitions. Do not commit rendered account-specific definitions unless intended.

## Required AWS architecture
1. VPC with public and private subnets, preferably in two Availability Zones.
2. Internet-facing ALB in public subnets, forwarding to the frontend ECS service on port 3000.
3. ECS Fargate cluster/services; frontend behind ALB and backend in private subnets.
4. Frontend security group accepts TCP 3000 only from the ALB security group. Backend security group accepts TCP 5000 only from the frontend task security group. Never expose backend port 5000 to `0.0.0.0/0`.
5. Backend service discovery or an internal load balancer provides the stable host in `BACKEND_URL`.
6. Configure NAT Gateway or suitable VPC endpoints for private task image pulls. These resources may incur charges.
7. Register task definitions, create services and ALB target group/listener, wait for stable services, inspect ECS events and CloudWatch logs, then test the live ALB URL and `/health` endpoints.

This package automates ECR image push and ECS task-definition rendering/registration; it does not create the VPC, ALB, cluster or services. Actual deployment evidence must come from your AWS account.

## Cleanup
Delete unused ECS services, ALB, NAT Gateway, public IP allocations and EBS volumes; check Billing. Stopping EC2 alone does not stop all charges.
