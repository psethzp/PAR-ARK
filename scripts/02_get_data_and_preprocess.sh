#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib_parark_runtime.sh"
STAGE=02_get_data_and_preprocess
stage_status "$STAGE" "RUNNING" "downloading STaRK data and checking ARK layout"
require_disk_budget
cd "$WORKDIR/ark"
# ARK expects data under benchmarks/stark and then symlink/run from that folder.
if [ ! -d benchmarks/stark ]; then
  mkdir -p benchmarks
  git clone https://github.com/snap-stanford/stark.git benchmarks/stark
fi
# Warm-download STaRK processed SKBs through stark-qa; this may take a while and needs disk.
uv run python - <<'PY'
from stark_qa import load_skb, load_qa
for name in ['prime','mag','amazon']:
    print('Downloading/loading', name)
    kb = load_skb(name, download_processed=True)
    qa = load_qa(name, human_generated_eval=False)
    print(name, 'nodes/edges maybe:', getattr(kb,'num_nodes',lambda:None)(), getattr(kb,'num_edges',lambda:None)(), 'qa_len', len(qa))
PY
checkpoint "$STAGE" "stark_qa processed cache warmed"

SNAPSHOT_DIR=$(find -L "$HF_HOME/hub/datasets--snap-stanford--stark/snapshots" -mindepth 1 -maxdepth 1 -type d | sort | tail -1)
if [ -z "$SNAPSHOT_DIR" ]; then
  echo "Could not find downloaded STaRK snapshot under $HF_HOME"
  exit 4
fi
echo "Using STaRK snapshot: $SNAPSHOT_DIR"

mkdir -p data/raw_graphs data/qa
for graph in prime mag amazon; do
  ln -sfn "$SNAPSHOT_DIR/skb/$graph/processed" "data/raw_graphs/$graph"
  ln -sfn "$SNAPSHOT_DIR/qa/$graph" "data/qa/$graph"
done
checkpoint "$STAGE" "linked STaRK snapshot into ARK raw_graphs and qa"

for f in preprocessing/prime_to_parquet.py preprocessing/mag_to_parquet.py preprocessing/amazon_to_parquet.py; do
  heartbeat "$STAGE" "running $f"
  uv run --no-sync python "$f"
  checkpoint "$STAGE" "completed $f"
  require_disk_budget
done

cd "$WORKDIR/ark/benchmarks/stark"
ln -sfn ../../src src
cd "$WORKDIR/ark"
uv run python - <<'PY'
from pathlib import Path
missing = []
for graph in ["prime", "mag", "amazon"]:
    for rel in [
        f"data/graphs/{graph}/nodes.parquet",
        f"data/graphs/{graph}/edges.parquet",
        f"data/qa/{graph}/stark_qa/stark_qa.csv",
        f"data/qa/{graph}/split/test.index",
    ]:
        if not Path(rel).exists():
            missing.append(rel)
if missing:
    print("Missing ARK expected paths:")
    for rel in missing:
        print("  " + rel)
    raise SystemExit(3)
print("ARK data layout verified")
PY
require_disk_budget
checkpoint "$STAGE" "data layout verified"
stage_status "$STAGE" "SUCCEEDED" "STaRK data ready"
printf "Data step complete. If ARK cannot find data/graphs or data/qa, inspect docs and symlink STaRK cache into ark/data/.\n"
