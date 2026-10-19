# Authentic deployment evidence checklist
Capture these yourself after running the commands in your own AWS account. Do not use mock images as proof.
- [ ] Single EC2: EC2 console instance details, terminal service status, browser live URL and successful form submission.
- [ ] Separate EC2: both instance IDs/private IPs, frontend BACKEND_URL, backend security-group rule allowing port 5000 only from frontend SG, live form result.
- [ ] ECR: `aws ecr describe-images --repository-name flask-backend --region "$AWS_REGION"` and the same command for `express-frontend`.
- [ ] ECS: `aws ecs describe-services --cluster YOUR_CLUSTER --services YOUR_FRONTEND_SERVICE YOUR_BACKEND_SERVICE --region "$AWS_REGION"`; show running/desired counts, events and task revisions.
- [ ] Rendered task definitions contain no unresolved placeholders.
- [ ] Browser shows live ALB URL, `/health` outputs and successful form submission.
- [ ] Real GitHub repository and application URLs added to README and Word report.
Never capture AWS secret keys, session tokens, private SSH keys or credentials.
