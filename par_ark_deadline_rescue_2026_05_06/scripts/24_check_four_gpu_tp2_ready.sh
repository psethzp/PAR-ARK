#!/usr/bin/env bash
set -euo pipefail

echo "== GPU memory/utilization =="
nvidia-smi --query-gpu=index,name,memory.used,utilization.gpu --format=csv

echo
echo "== Compute apps =="
nvidia-smi --query-compute-apps=gpu_uuid,pid,process_name,used_memory --format=csv,noheader,nounits || true

echo
echo "== Relevant process commands =="
pids=$(nvidia-smi --query-compute-apps=pid --format=csv,noheader,nounits 2>/dev/null | sort -u | tr '\n' ' ')
if [ -n "$pids" ]; then
  ps -o pid,ppid,user,stat,lstart,cmd -p $pids || true
else
  echo "No GPU compute processes found."
fi

echo
echo "Four-GPU two-TP2 readiness requires two free pairs, normally: 0,3 and 1,2."
