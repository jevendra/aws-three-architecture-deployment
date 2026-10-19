# AWS Deployment: Flask Backend + Express Frontend

This repository is a deployment-ready starter for three required configurations:
1. One EC2 instance running both apps.
2. Two EC2 instances, frontend and backend separated.
3. Docker images in ECR and services on ECS/Fargate inside a VPC.

## Application
- Express frontend: port 3000, serves form and forwards JSON to Flask.
- Flask backend: port 5000, validates and processes form data.
- Success redirects to `/success`; failures display on the original form.

## Quick local test
Backend:
```bash
cd app/backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python app.py
```
Frontend in a second terminal:
```bash
cd app/frontend
npm install
BACKEND_URL=http://127.0.0.1:5000 npm start
```
Open http://localhost:3000. On Windows PowerShell set `$env:BACKEND_URL="http://127.0.0.1:5000"` before `npm start`.

## Deployment instructions
- Single EC2: `deploy/single_ec2/setup.sh` plus `docs` and `systemd`/reverse proxy guidance in the Word documentation.
- Separate EC2: `deploy/separate_ec2/README.md`.
- ECS/ECR/VPC: `deploy/ecs/README.md`, task-definition templates, and `scripts/push-to-ecr.sh`.

## Container build and local smoke test
Both Dockerfiles are included. With Docker installed, run `docker compose up --build`, test `http://localhost:3000`, then run `docker compose down`. Use `deploy/ecs/render-task-definitions.sh` to render ECS definitions after setting real account/role/network values.

## Links to fill in after real deployment
- Application URL: `NOT_DEPLOYED_YET`
- GitHub repository: `PASTE_YOUR_GITHUB_REPOSITORY_URL_HERE`

AWS resources are not created by generating this source package. The package includes Dockerfiles, an ECR push script, and an ECS task-definition renderer, but infrastructure still must be deployed in your AWS account. Deploy in your own AWS account, test the live URL, and paste the real URL and GitHub repository link into the documentation. Review pricing and clean up resources after testing.
