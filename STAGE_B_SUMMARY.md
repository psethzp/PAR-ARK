# Stage B Summary

Updated: 2026-05-05T15:38:04Z

## Completion

- Stage A validation grid is complete: 24/24 Qwen3-14B validation cells have `metrics_summary.json`.
- Idle Qwen3-14B vLLM was stopped after Stage A; GPUs 1, 2, and 3 are free.
- Stage B table collection succeeded and wrote:
  - `/home/ubuntu/par_ark_workspace/ark/paper_tables/par_ark_tables.md`

## Validation Signal

Best configurations by graph on the 100-question validation slice:

| Graph | Best MRR | Best Hit@5 | Best Recall@20 |
|---|---|---|---|
| prime | off steps=12, MRR 0.2736 | profile steps=16, Hit@5 0.3600 | profile steps=16, R@20 0.3545 |
| mag | off steps=16, MRR 0.4683 | off steps=16, Hit@5 0.5700 | off steps=16, R@20 0.5127 |
| amazon | off steps=16, MRR 0.5165 | off steps=12/16, Hit@5 0.6300 | off steps=16, R@20 0.4338 |

Average across graphs:

| Mode | Steps | Avg MRR | Avg Hit@5 | Avg R@20 | Avg Time |
|---|---:|---:|---:|---:|---:|
| off | 12 | 0.4087 | 0.5100 | 0.4252 | 25.94s |
| off | 16 | 0.4058 | 0.5067 | 0.4192 | 27.38s |
| profile | 12 | 0.3511 | 0.4533 | 0.3845 | 27.98s |
| profile | 16 | 0.3473 | 0.4700 | 0.3848 | 26.78s |
| trace | 12 | 0.2944 | 0.3767 | 0.2840 | 21.08s |
| trace | 16 | 0.3307 | 0.4167 | 0.3195 | 19.99s |
| full | 12 | 0.3141 | 0.3951 | 0.3036 | 21.29s |
| full | 16 | 0.3103 | 0.3900 | 0.2998 | 22.07s |

## Recommendation

For Stage C, run the full test comparison exactly as planned:

- Baseline/control: `par_mode=off`, `max_steps=16`
- PAR-ARK candidate: `par_mode=full`, `max_steps=16`

Reasoning:

- Validation accuracy favors `off`, so it remains the main baseline/control.
- `full` is the intended PAR-ARK mechanism and still needs a full-test measurement for paper evidence, despite losing on this 14B validation slice.
- Keep `max_steps=16` for Stage C because the existing final-test script is already configured that way and it is the fairest fixed-depth comparison across graphs.

Important caveat:

- One Amazon full steps=12 validation run reported `n=99`, while all other Stage A cells were `n=100`. This does not block Stage C, but it should be checked before paper tables are finalized.
