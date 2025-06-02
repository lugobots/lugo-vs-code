#!/bin/bash
cd /home/coder/project
if [ -f requirements.txt ]; then
  python3.9 -m venv venv
  . venv/bin/activate
  pip install -r requirements.txt
fi

if [ -f go.mod ]; then
  go mod vendor ||echo "failed to download dependencies"
fi

if [ -f package.json ]; then
  npm install || echo "failed to install dependencies"
fi


if [ -z "$PORT" ]; then
  PORT=8082  # default value
fi


exec /usr/bin/code-server \
   --auth none \
  --disable-telemetry \
  --disable-update-check \
  --disable-workspace-trust \
  --bind-addr 0.0.0.0:${PORT} /home/coder/project "$@"
