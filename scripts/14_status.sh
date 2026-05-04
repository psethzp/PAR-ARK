#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"

echo "== PAR-ARK status =="
echo "WORKDIR=$WORKDIR"
echo "RUN_STATE=$PARARK_RUN_ROOT"
echo

echo "== Stage statuses =="
if compgen -G "$PARARK_STATUS_DIR/*.status" >/dev/null; then
  for f in "$PARARK_STATUS_DIR"/*.status; do
    echo "--- $(basename "$f")"
    cat "$f"
  done
else
  echo "No stage statuses yet."
fi
echo

echo "== Heartbeats =="
if compgen -G "$PARARK_STATUS_DIR/*.heartbeat" >/dev/null; then
  for f in "$PARARK_STATUS_DIR"/*.heartbeat; do
    echo "--- $(basename "$f")"
    cat "$f"
  done
else
  echo "No heartbeats yet."
fi
echo

echo "== Recent logs =="
find "$PARARK_LOG_DIR" -maxdepth 1 -type f -printf "%TY-%Tm-%Td %TH:%TM %s %p\n" 2>/dev/null | sort | tail -20 || true
echo

echo "== GPU =="
nvidia-smi --query-gpu=index,name,memory.total,memory.used,utilization.gpu --format=csv || true
echo

echo "== Workspace disk =="
du -sh "$WORKDIR" 2>/dev/null || true
df -h "$WORKDIR" 2>/dev/null || true
