#!/bin/sh
set -eu

CODEX_GATEWAY_HOST="${CODEX_GATEWAY_HOST:-0.0.0.0}"

if [ -n "${PORT:-}" ] && [ -z "${CODEX_GATEWAY_PORT:-}" ]; then
  CODEX_GATEWAY_PORT="${PORT}"
else
  CODEX_GATEWAY_PORT="${CODEX_GATEWAY_PORT:-8000}"
fi

PROVIDER="${CODEX_PROVIDER:-cursor-agent}"
LOG_LEVEL="${CODEX_LOG_LEVEL:-info}"

export CODEX_GATEWAY_HOST
export CODEX_GATEWAY_PORT

exec node dist/cli.js "${PROVIDER}" \
  --host "${CODEX_GATEWAY_HOST}" \
  --port "${CODEX_GATEWAY_PORT}" \
  --log-level "${LOG_LEVEL}"
