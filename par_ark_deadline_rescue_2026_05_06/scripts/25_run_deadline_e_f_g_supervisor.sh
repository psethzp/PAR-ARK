#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/lib_parark_runtime.sh"

STAGE=${STAGE:-25_run_deadline_e_f_g_supervisor}
MODEL_SHORT=${MODEL_SHORT:-Qwen3-30B-A3B-Instruct-2507}
LIMIT_E=${LIMIT_E:-300}
STEPS_E=${STEPS_E:-16}
LIMIT_F=${LIMIT_F:-150}
STEPS_F=${STEPS_F:-8}
MAX_GLOBAL=${MAX_GLOBAL:-2}
MAX_NEIGH=${MAX_NEIGH:-3}
MAX_OBS=${MAX_OBS:-2500}
MAX_ANS=${MAX_ANS:-10}
POLL_SECONDS=${POLL_SECONDS:-300}
PORT_A=${PORT_A:-8000}
PORT_B=${PORT_B:-8100}

cd "$PACKAGE_DIR"

count_stage_e_metrics() {
  find "$WORKDIR/ark/data/experiments" -path "*deadline_*q30b_limit${LIMIT_E}_s${STEPS_E}*/metrics_summary.json" | wc -l
}

count_stage_f_metrics() {
  find "$WORKDIR/ark/data/experiments" -path "*deadline_budgetfix_q30b_limit${LIMIT_F}_s${STEPS_F}_g${MAX_GLOBAL}_n${MAX_NEIGH}_obs${MAX_OBS}*/metrics_summary.json" | wc -l
}

stage_status "$STAGE" "RUNNING" "watching Stage E, then launching Stage F shards and Stage G diagnostics"
checkpoint "$STAGE" "supervisor started; Stage E target metrics=6 Stage F target metrics=3"

last_log=0
while true; do
  n=$(count_stage_e_metrics)
  if [ "$n" -ge 6 ]; then
    checkpoint "$STAGE" "Stage E metrics complete: $n/6"
    break
  fi
  now=$(date +%s)
  if [ $((now - last_log)) -ge 1800 ]; then
    runbook_log "[${STAGE}] waiting for Stage E metrics: ${n}/6 complete"
    last_log=$now
  fi
  sleep "$POLL_SECONDS"
done

checkpoint "$STAGE" "launching Stage F two-replica budget-fix shards"

LIMIT=$LIMIT_F MAX_STEPS=$STEPS_F MAX_GLOBAL=$MAX_GLOBAL MAX_NEIGH=$MAX_NEIGH MAX_OBS=$MAX_OBS MAX_ANS=$MAX_ANS \
VLLM_PORT=$PORT_A GRAPHS="prime amazon" SHARD_NAME=f_a_${PORT_A} \
bash scripts/16_run_detached.sh \
  19_run_stage_f_budgetfix_probe_shard_a_${PORT_A} \
  env LIMIT=$LIMIT_F MAX_STEPS=$STEPS_F MAX_GLOBAL=$MAX_GLOBAL MAX_NEIGH=$MAX_NEIGH MAX_OBS=$MAX_OBS MAX_ANS=$MAX_ANS \
      VLLM_PORT=$PORT_A GRAPHS="prime amazon" SHARD_NAME=f_a_${PORT_A} \
      bash par_ark_deadline_rescue_2026_05_06/scripts/23_run_stage_f_budgetfix_probe_shard.sh

LIMIT=$LIMIT_F MAX_STEPS=$STEPS_F MAX_GLOBAL=$MAX_GLOBAL MAX_NEIGH=$MAX_NEIGH MAX_OBS=$MAX_OBS MAX_ANS=$MAX_ANS \
VLLM_PORT=$PORT_B GRAPHS="mag" SHARD_NAME=f_b_${PORT_B} \
bash scripts/16_run_detached.sh \
  19_run_stage_f_budgetfix_probe_shard_b_${PORT_B} \
  env LIMIT=$LIMIT_F MAX_STEPS=$STEPS_F MAX_GLOBAL=$MAX_GLOBAL MAX_NEIGH=$MAX_NEIGH MAX_OBS=$MAX_OBS MAX_ANS=$MAX_ANS \
      VLLM_PORT=$PORT_B GRAPHS="mag" SHARD_NAME=f_b_${PORT_B} \
      bash par_ark_deadline_rescue_2026_05_06/scripts/23_run_stage_f_budgetfix_probe_shard.sh

last_log=0
while true; do
  n=$(count_stage_f_metrics)
  if [ "$n" -ge 3 ]; then
    checkpoint "$STAGE" "Stage F metrics complete: $n/3"
    break
  fi
  now=$(date +%s)
  if [ $((now - last_log)) -ge 1800 ]; then
    runbook_log "[${STAGE}] waiting for Stage F metrics: ${n}/3 complete"
    last_log=$now
  fi
  sleep "$POLL_SECONDS"
done

checkpoint "$STAGE" "running Stage G paired diagnostics and regenerating tables"

cd "$WORKDIR/ark"
mkdir -p paper_tables
for GRAPH in prime mag amazon; do
  python "$PACKAGE_DIR/par_ark_deadline_rescue_2026_05_06/scripts/21_pair_diagnostics.py" \
    --off_dir "$WORKDIR/ark/data/experiments/$GRAPH/graph_explorer_${MODEL_SHORT}_deadline_off_q30b_limit${LIMIT_E}_s${STEPS_E}/test" \
    --full_dir "$WORKDIR/ark/data/experiments/$GRAPH/graph_explorer_${MODEL_SHORT}_par_full_deadline_full_q30b_limit${LIMIT_E}_s${STEPS_E}/test" \
    --out "$WORKDIR/ark/paper_tables/${GRAPH}_deadline_pair_diagnostics.md"
done

uv run python scripts/make_par_tables.py --out paper_tables/deadline_all_tables.md || true

stage_status "$STAGE" "SUCCEEDED" "Stage E/F/G supervisor complete; diagnostics and tables attempted"
checkpoint "$STAGE" "completed successfully"
