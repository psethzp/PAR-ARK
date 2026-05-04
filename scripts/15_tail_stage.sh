#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"

stage=${1:-}
if [ -z "$stage" ]; then
  echo "Usage: bash scripts/15_tail_stage.sh <stage-name>"
  echo "Known logs:"
  find "$PARARK_LOG_DIR" -maxdepth 1 -type f -printf "  %f\n" 2>/dev/null | sort || true
  exit 2
fi

log="$PARARK_LOG_DIR/${stage}.log"
if [ ! -f "$log" ]; then
  echo "No log found at $log"
  exit 1
fi

tail -n "${TAIL_LINES:-120}" -f "$log"
