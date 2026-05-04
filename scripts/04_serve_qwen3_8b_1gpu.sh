#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"
STAGE=04_serve_qwen3_8b_1gpu
stage_status "$STAGE" "RUNNING" "starting vLLM Qwen3-8B on GPU $PARARK_GPU_1"
require_disk_budget
cd "$WORKDIR/ark"
export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-$PARARK_GPU_1}
export VLLM_PORT=${VLLM_PORT:-8000}
checkpoint "$STAGE" "launching vLLM on CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"
uv run vllm serve Qwen/Qwen3-8B \
  --served-model-name Qwen/Qwen3-8B \
  --host 0.0.0.0 --port "$VLLM_PORT" \
  --dtype bfloat16 \
  --max-model-len 16384 \
  --max-num-seqs 1 \
  --gpu-memory-utilization 0.82 \
  --enable-auto-tool-choice \
  --tool-call-parser hermes
