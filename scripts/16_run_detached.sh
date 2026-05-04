#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"

stage=${1:-}
shift || true
if [ -z "$stage" ] || [ "$#" -eq 0 ]; then
  echo "Usage: bash scripts/16_run_detached.sh <stage-name> <command...>"
  exit 2
fi

log="$PARARK_LOG_DIR/${stage}.detached.log"
pidfile="$PARARK_STATUS_DIR/${stage}.pid"
stage_status "$stage" "LAUNCHING" "detached log=$log"

cmd_file="$PARARK_RUN_ROOT/${stage}.cmd.sh"
{
  printf "#!/usr/bin/env bash\n"
  printf "set -euo pipefail\n"
  printf "cd %q\n" "$PACKAGE_DIR"
  printf "export PACKAGE_DIR=%q\n" "$PACKAGE_DIR"
  printf "export WORKDIR=%q\n" "$WORKDIR"
  printf "export PARARK_GPU_1=%q\n" "$PARARK_GPU_1"
  printf "export PARARK_GPUS_2=%q\n" "$PARARK_GPUS_2"
  printf "export PARARK_DISK_BUDGET_GB=%q\n" "$PARARK_DISK_BUDGET_GB"
  printf "source %q\n" "$PACKAGE_DIR/scripts/lib_parark_runtime.sh"
  printf "run_logged %q" "$stage"
  for arg in "$@"; do
    printf " %q" "$arg"
  done
  printf "\n"
} > "$cmd_file"
chmod +x "$cmd_file"

setsid nohup bash "$cmd_file" >> "$log" 2>&1 < /dev/null &

pid=$!
echo "$pid" > "$pidfile"
stage_status "$stage" "DETACHED" "pid=$pid log=$log"
echo "Started $stage as pid $pid"
echo "Status: bash scripts/14_status.sh"
echo "Tail:   bash scripts/15_tail_stage.sh $stage"
