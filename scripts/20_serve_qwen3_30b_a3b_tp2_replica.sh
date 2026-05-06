#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"

STAGE=${STAGE:-20_serve_qwen3_30b_a3b_tp2_replica}
MODEL=${MODEL:-Qwen/Qwen3-30B-A3B-Instruct-2507}
MODEL_LEN=${MODEL_LEN:-32768}
GPU_MEMORY_UTILIZATION=${GPU_MEMORY_UTILIZATION:-0.90}

stage_status "$STAGE" "RUNNING" "starting TP2 vLLM replica on GPUs ${PARARK_GPUS_2} port ${VLLM_PORT}"
require_disk_budget

cd "$WORKDIR/ark"
export CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-$PARARK_GPUS_2}

checkpoint "$STAGE" "launching TP2 vLLM replica model=$MODEL CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES port=$VLLM_PORT max_model_len=$MODEL_LEN gpu_memory_utilization=$GPU_MEMORY_UTILIZATION"

uv run vllm serve "$MODEL" \
  --served-model-name "$MODEL" \
  --host 0.0.0.0 --port "$VLLM_PORT" \
  --dtype bfloat16 \
  --tensor-parallel-size 2 \
  --max-model-len "$MODEL_LEN" \
  --max-num-seqs 1 \
  --gpu-memory-utilization "$GPU_MEMORY_UTILIZATION" \
  --enable-auto-tool-choice \
  --tool-call-parser hermes
