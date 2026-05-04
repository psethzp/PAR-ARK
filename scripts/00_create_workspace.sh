#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"
STAGE=00_create_workspace
stage_status "$STAGE" "RUNNING" "creating ARK workspace"
require_disk_budget
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ark ]; then
  git clone https://github.com/mims-harvard/ark.git
else
  echo "ARK already exists at $WORKDIR/ark; leaving it in place for resume safety."
fi
cd ark
git rev-parse HEAD > ../ARK_COMMIT.txt
mkdir -p logs
checkpoint "$STAGE" "ARK commit $(cat ../ARK_COMMIT.txt)"
stage_status "$STAGE" "SUCCEEDED" "Workspace ready at $WORKDIR/ark"
printf "Workspace ready at %s/ark\n" "$WORKDIR"
