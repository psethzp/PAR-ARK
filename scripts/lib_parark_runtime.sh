#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR=${PACKAGE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
PARARK_GPU_1=${PARARK_GPU_1:-1}
PARARK_GPUS_2=${PARARK_GPUS_2:-1,2}
PARARK_DISK_BUDGET_GB=${PARARK_DISK_BUDGET_GB:-700}
PARARK_RUN_ROOT=${PARARK_RUN_ROOT:-$WORKDIR/run_state}
PARARK_CACHE_DIR=${PARARK_CACHE_DIR:-$WORKDIR/cache}
PARARK_STATUS_DIR=${PARARK_STATUS_DIR:-$PARARK_RUN_ROOT/status}
PARARK_LOG_DIR=${PARARK_LOG_DIR:-$PARARK_RUN_ROOT/logs}
PARARK_CHECKPOINT_DIR=${PARARK_CHECKPOINT_DIR:-$PARARK_RUN_ROOT/checkpoints}
RUNBOOK=${RUNBOOK:-$PACKAGE_DIR/RUNBOOK.md}

mkdir -p "$PARARK_STATUS_DIR" "$PARARK_LOG_DIR" "$PARARK_CHECKPOINT_DIR" "$PARARK_CACHE_DIR"

export PATH="$HOME/.local/bin:$PATH"
export PACKAGE_DIR WORKDIR PARARK_GPU_1 PARARK_GPUS_2 PARARK_DISK_BUDGET_GB
export HF_HOME=${HF_HOME:-$PARARK_CACHE_DIR/huggingface}
export HUGGINGFACE_HUB_CACHE=${HUGGINGFACE_HUB_CACHE:-$HF_HOME/hub}
export TRANSFORMERS_CACHE=${TRANSFORMERS_CACHE:-$HF_HOME/transformers}
export HF_HUB_ENABLE_HF_TRANSFER=${HF_HUB_ENABLE_HF_TRANSFER:-1}
export VLLM_PORT=${VLLM_PORT:-8000}
export TOKENIZERS_PARALLELISM=${TOKENIZERS_PARALLELISM:-false}
export VLLM_ALLOW_LONG_MAX_MODEL_LEN=${VLLM_ALLOW_LONG_MAX_MODEL_LEN:-1}
export UV_NO_SYNC=${UV_NO_SYNC:-1}
export PYTHONUNBUFFERED=${PYTHONUNBUFFERED:-1}

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

runbook_log() {
  local msg="$*"
  mkdir -p "$(dirname "$RUNBOOK")"
  if [ ! -f "$RUNBOOK" ]; then
    {
      printf "# PAR-ARK Runbook\n\n"
      printf "This file is updated by the PAR-ARK runtime scripts. Times are UTC.\n\n"
      printf "## Event Log\n\n"
    } > "$RUNBOOK"
  fi
  printf -- "- %s %s\n" "$(timestamp)" "$msg" >> "$RUNBOOK"
}

stage_status() {
  local stage="$1"
  local status="$2"
  local detail="${3:-}"
  local file="$PARARK_STATUS_DIR/${stage}.status"
  {
    printf "stage=%s\n" "$stage"
    printf "status=%s\n" "$status"
    printf "updated_at=%s\n" "$(timestamp)"
    printf "pid=%s\n" "$$"
    printf "detail=%s\n" "$detail"
  } > "$file"
  runbook_log "[${stage}] ${status}: ${detail}"
}

heartbeat() {
  local stage="$1"
  local detail="${2:-running}"
  {
    printf "stage=%s\n" "$stage"
    printf "updated_at=%s\n" "$(timestamp)"
    printf "pid=%s\n" "$$"
    printf "detail=%s\n" "$detail"
  } > "$PARARK_STATUS_DIR/${stage}.heartbeat"
}

checkpoint() {
  local stage="$1"
  local detail="${2:-checkpoint}"
  {
    printf "stage=%s\n" "$stage"
    printf "checkpoint_at=%s\n" "$(timestamp)"
    printf "detail=%s\n" "$detail"
  } > "$PARARK_CHECKPOINT_DIR/${stage}.latest"
  runbook_log "[${stage}] checkpoint: ${detail}"
}

require_disk_budget() {
  local used_gb
  used_gb=$(du -sBG "$WORKDIR" 2>/dev/null | awk '{gsub("G","",$1); print $1 + 0}')
  if [ "$used_gb" -gt "$PARARK_DISK_BUDGET_GB" ]; then
    stage_status "disk_budget" "FAILED" "WORKDIR uses ${used_gb}GB > budget ${PARARK_DISK_BUDGET_GB}GB"
    return 1
  fi
  runbook_log "[disk] WORKDIR usage ${used_gb}GB within ${PARARK_DISK_BUDGET_GB}GB budget"
}

log_env_snapshot() {
  local stage="$1"
  {
    printf "timestamp=%s\n" "$(timestamp)"
    printf "PACKAGE_DIR=%s\n" "$PACKAGE_DIR"
    printf "WORKDIR=%s\n" "$WORKDIR"
    printf "PARARK_GPU_1=%s\n" "$PARARK_GPU_1"
    printf "PARARK_GPUS_2=%s\n" "$PARARK_GPUS_2"
    printf "PARARK_DISK_BUDGET_GB=%s\n" "$PARARK_DISK_BUDGET_GB"
    printf "HF_HOME=%s\n" "$HF_HOME"
    printf "VLLM_PORT=%s\n" "$VLLM_PORT"
    nvidia-smi --query-gpu=index,name,memory.total,memory.used,utilization.gpu --format=csv,noheader 2>/dev/null || true
    df -h "$WORKDIR" "$PACKAGE_DIR" 2>/dev/null || true
  } > "$PARARK_LOG_DIR/${stage}.env"
}

run_logged() {
  local stage="$1"
  shift
  local log="$PARARK_LOG_DIR/${stage}.log"
  stage_status "$stage" "RUNNING" "log=$log"
  log_env_snapshot "$stage"
  heartbeat "$stage" "started"
  set +e
  {
    printf "===== %s START %s =====\n" "$stage" "$(timestamp)"
    printf "COMMAND:"
    printf " %q" "$@"
    printf "\n"
    "$@"
    rc=$?
    printf "===== %s EXIT %s rc=%s =====\n" "$stage" "$(timestamp)" "$rc"
    exit "$rc"
  } 2>&1 | tee -a "$log"
  rc=${PIPESTATUS[0]}
  set -e
  if [ "$rc" -eq 0 ]; then
    stage_status "$stage" "SUCCEEDED" "log=$log"
    checkpoint "$stage" "completed successfully"
  else
    stage_status "$stage" "FAILED" "rc=$rc log=$log"
  fi
  return "$rc"
}
