#!/bin/bash
cd /home/coder/project

if [ -z "$PORT" ]; then
  PORT=8082
fi

exec /usr/bin/code-server \
  --auth none \
  --disable-telemetry \
  --disable-update-check \
  --disable-workspace-trust \
  --bind-addr "0.0.0.0:${PORT}" \
  /home/coder/project "$@"
