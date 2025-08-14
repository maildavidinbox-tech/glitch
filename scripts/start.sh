# #!/bin/bash
# set -euo pipefail
# cd /home/ubuntu/app
# nohup python3 -m http.server 8080 > server.log 2>&1 &

#!/bin/bash
set -euo pipefail
cd /home/ubuntu/app

# stop anything that might be on 8080 (ignore errors)
fuser -k 8080/tcp 2>/dev/null || true

# start a tiny HTTP server in background and log to file
nohup python3 -m http.server 8080 > server.log 2>&1 &
echo "[start.sh] started: $(date)" >> server.log
