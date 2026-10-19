#!/usr/bin/env bash
set -euo pipefail
: "${AWS_REGION:?Set AWS_REGION, e.g. ap-south-1}"
: "${ECS_TASK_EXECUTION_ROLE_ARN:?Set the full ECS task execution role ARN}"
: "${BACKEND_URL:?Set the backend private service URL, e.g. http://flask-backend.internal:5000}"
: "${FRONTEND_ORIGIN:?Set the frontend origin, e.g. http://your-alb-dns-name}"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text --region "$AWS_REGION")"
IMAGE_TAG="${IMAGE_TAG:-latest}"
export AWS_REGION ECS_TASK_EXECUTION_ROLE_ARN BACKEND_URL FRONTEND_ORIGIN AWS_ACCOUNT_ID IMAGE_TAG
mkdir -p deploy/ecs/rendered
python3 - <<'PY'
import json, os, pathlib, re
for kind in ('backend','frontend'):
    src=pathlib.Path(f'deploy/ecs/task-definition-{kind}.json')
    dst=pathlib.Path(f'deploy/ecs/rendered/task-definition-{kind}.json')
    raw=re.sub(r'\$\{([A-Z0-9_]+)\}', lambda m: os.environ.get(m.group(1), m.group(0)), src.read_text())
    if re.search(r'\$\{[A-Z0-9_]+\}|REPLACE_WITH|AWS_ACCOUNT_ID|AWS_REGION', raw):
        raise SystemExit(f'Unresolved placeholder in {src}')
    obj=json.loads(raw)
    assert obj['executionRoleArn'].startswith('arn:aws:iam::')
    assert obj['containerDefinitions'][0]['image'].startswith(os.environ['AWS_ACCOUNT_ID']+'.dkr.ecr.'+os.environ['AWS_REGION']+'.amazonaws.com/')
    dst.write_text(json.dumps(obj,indent=2)+'\n')
    print(f'Rendered {dst}')
PY
for service in flask-backend express-frontend; do
  aws logs create-log-group --log-group-name "/ecs/$service" --region "$AWS_REGION" 2>/dev/null || true
done
if [[ "${REGISTER_TASKS:-0}" == "1" ]]; then
  aws ecs register-task-definition --cli-input-json file://deploy/ecs/rendered/task-definition-backend.json --region "$AWS_REGION"
  aws ecs register-task-definition --cli-input-json file://deploy/ecs/rendered/task-definition-frontend.json --region "$AWS_REGION"
else
  echo "Rendered only. Review JSON; set REGISTER_TASKS=1 to register task definitions."
fi
