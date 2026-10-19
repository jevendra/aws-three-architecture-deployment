#!/usr/bin/env bash
# Run on Ubuntu EC2 after uploading the app/ folder.
set -euo pipefail
sudo apt-get update
sudo apt-get install -y python3-venv python3-pip nodejs npm
APP_DIR="${APP_DIR:-$HOME/aws-flask-express/app}"
python3 -m venv "$APP_DIR/backend/.venv"
"$APP_DIR/backend/.venv/bin/pip" install -r "$APP_DIR/backend/requirements.txt"
cd "$APP_DIR/frontend"
npm install --omit=dev
echo "Start Flask on 127.0.0.1:5000 with systemd or nohup."
echo "Start Express on 0.0.0.0:3000 with BACKEND_URL=http://127.0.0.1:5000."
echo "Open TCP/3000 only from your IP in the EC2 security group for a demo."
