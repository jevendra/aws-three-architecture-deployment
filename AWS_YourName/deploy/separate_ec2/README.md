#!/usr/bin/env bash
# Run backend section on backend EC2; frontend section on frontend EC2.
# Backend EC2: install Python, upload app/backend, install requirements, bind Flask to 0.0.0.0:5000.
# Frontend EC2: install Node.js, upload app/frontend, npm install --omit=dev,
# set BACKEND_URL=http://BACKEND_PRIVATE_IP:5000, then npm start.
# Security groups: frontend inbound TCP/3000 from your IP; backend TCP/5000 only
# from the frontend EC2 security group. Do not expose backend port to 0.0.0.0/0.
