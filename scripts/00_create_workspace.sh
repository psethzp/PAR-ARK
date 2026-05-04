#!/usr/bin/env bash
set -euo pipefail
export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [ ! -d ark ]; then
  git clone https://github.com/mims-harvard/ark.git
fi
cd ark
git rev-parse HEAD > ../ARK_COMMIT.txt
mkdir -p logs
printf "Workspace ready at %s/ark\n" "$WORKDIR"
