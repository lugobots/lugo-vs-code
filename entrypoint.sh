#!/bin/bash

# Suppress all output
exec > /dev/null 2>&1

cd /home/coder/project

# these are the files used to check the existence of a Lugo Project in the directory
PY_PROJECT="requirements.txt"
FJ_PROJECT="package.json"
GO_PROJECT="go.mod"

while true; do
  if [ -f requirements.txt ]; then
   sudo python3.9 -m venv .studio/venv-lugo-vs
   source .studio/venv-lugo-vs/bin/activate
   sudo .studio/venv-lugo-vs/bin/pip install -r requirements.txt
   break
  fi

  if [ -f go.mod ]; then
    go mod vendor ||echo "failed to download dependencies"
    break
  fi

  if [ -f package.json ]; then
    npm install || echo "failed to install dependencies"
    break
  fi

#  echo "No project found yet. Install a Lugo Bot project"
  sleep 1
done

if [ -z "$PORT" ]; then
  PORT=8082  # default value
fi



exec /usr/bin/code-server \
   --auth none \
  --disable-telemetry \
  --disable-update-check \
  --disable-workspace-trust \
  --bind-addr 0.0.0.0:${PORT} /home/coder/project "$@"
