#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"

STAGE=13_preflight_current_env
stage_status "$STAGE" "RUNNING" "checking local constraints"
mkdir -p "$WORKDIR"
log_env_snapshot "$STAGE"

echo "Package: $PACKAGE_DIR"
echo "Workspace: $WORKDIR"
echo "Cache: $HF_HOME"
echo "Disk budget: ${PARARK_DISK_BUDGET_GB}GB"
echo "1-GPU default: $PARARK_GPU_1"
echo "2-GPU default: $PARARK_GPUS_2"

require_disk_budget

echo "GPU snapshot:"
nvidia-smi --query-gpu=index,name,memory.total,memory.used,utilization.gpu --format=csv

echo "Disk snapshot:"
df -h "$PACKAGE_DIR" "$WORKDIR"

echo "Tool snapshot:"
python3 --version
git --version
curl --version | head -1
if command -v uv >/dev/null 2>&1; then
  uv --version
else
  echo "uv not installed yet; setup stage will install it"
fi

echo "Checking model metadata access:"
for model in \
  Qwen/Qwen3-8B \
  Qwen/Qwen3-14B \
  Qwen/Qwen3-30B-A3B-Instruct-2507 \
  Qwen/Qwen3-Reranker-8B
do
  curl -sSfL "https://huggingface.co/api/models/${model}" >/dev/null
  echo "ok ${model}"
done

bash -n "$PACKAGE_DIR"/scripts/*.sh
python3 -m py_compile "$PACKAGE_DIR/patches/apply_par_ark_overlay.py"

checkpoint "$STAGE" "preflight passed"
stage_status "$STAGE" "SUCCEEDED" "current environment is usable"
