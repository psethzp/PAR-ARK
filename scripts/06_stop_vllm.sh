#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"
STAGE=06_stop_vllm
stage_status "$STAGE" "RUNNING" "stopping vLLM processes"
pkill -f "vllm serve" || true
pkill -f "vllm.entrypoints" || true
sleep 5
nvidia-smi || true
checkpoint "$STAGE" "vLLM stop attempted"
stage_status "$STAGE" "SUCCEEDED" "vLLM stop attempted"
