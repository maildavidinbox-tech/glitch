#!/bin/bash
set -euo pipefail
cd /home/ubuntu/app
nohup python3 -m http.server 8080 > server.log 2>&1 &