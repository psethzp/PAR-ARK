# ETA and Settings

## Empirical speed from Stage B2

Stage B2 processed roughly 299 usable question cells.

Using the `TimeMean(s)` values in RESULTS.md:

- prime/off: 49 × 9.435 = 462 s
- prime/full: 50 × 7.444 = 372 s
- mag/off: 49 × 12.483 = 612 s
- mag/full: 50 × 6.951 = 348 s
- amazon/off: 50 × 10.251 = 513 s
- amazon/full: 50 × 6.333 = 317 s
- total measured per-question time: 2,624 s = 43.7 min

Observed wall time was about 85 min, so the practical overhead factor is about 1.9–2.0×.

## Runtime estimates on one TP2 server with 2×L40

| Limit per graph/mode | Total questions | Estimated wall time | Use case |
|---:|---:|---:|---|
| 150 | 900 | 4.2–4.5 h | emergency minimum |
| 200 | 1,200 | 5.6–6.0 h | safe default if starting late |
| 250 | 1,500 | 7.0–7.5 h | good balance |
| 300 | 1,800 | 8.4–9.0 h | best deadline subset |
| 500 | 3,000 | 14–15 h | only if started very early |

## vLLM serving setting

Keep the already-working server first. If context errors repeat, restart with a slightly larger context window only if memory allows.

Conservative working setting from previous package:

```bash
vllm serve Qwen/Qwen3-30B-A3B-Instruct-2507 \
  --tensor-parallel-size 2 \
  --max-model-len 32768 \
  --max-num-seqs 1 \
  --gpu-memory-utilization 0.90
```

If the `prime/off` context error repeats frequently, try:

```bash
vllm serve Qwen/Qwen3-30B-A3B-Instruct-2507 \
  --tensor-parallel-size 2 \
  --max-model-len 40960 \
  --max-num-seqs 1 \
  --gpu-memory-utilization 0.92
```

Use only one 30B server on 2 GPUs. Do not load reranker simultaneously.

## Paper-safe settings

Main subset:

```bash
LIMIT=300 MAX_STEPS=16 bash scripts/18_run_stage_e_30b_subset.sh
```

Emergency subset:

```bash
LIMIT=200 MAX_STEPS=16 bash scripts/18_run_stage_e_30b_subset.sh
```

Budget-fix probe:

```bash
LIMIT=150 MAX_STEPS=8 MAX_GLOBAL=2 MAX_NEIGH=3 MAX_OBS=2500 MAX_ANS=10 \
  bash scripts/19_run_stage_f_budgetfix_probe.sh
```
