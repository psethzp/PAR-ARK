#!/usr/bin/env bash
set -euo pipefail
export WORKDIR=${WORKDIR:-$HOME/par_ark_workspace}
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
# Follow ARK preprocessing if raw graph files are available in the expected locations.
# Some installs require placing raw files manually under benchmarks/stark/data/raw_graphs/ first.
if [ -d benchmarks/stark/preprocessing ]; then
  cd benchmarks/stark/preprocessing
  for f in prime_to_parquet.py mag_to_parquet.py amazon_to_parquet.py; do
    if [ -f "$f" ]; then uv run python "$f" || echo "Preprocess $f failed; check raw graph paths."; fi
  done
fi
cd "$WORKDIR/ark/benchmarks/stark"
ln -sfn ../../src src
printf "Data step complete. If ARK cannot find data/graphs or data/qa, inspect docs and symlink STaRK cache into ark/data/.\n"
