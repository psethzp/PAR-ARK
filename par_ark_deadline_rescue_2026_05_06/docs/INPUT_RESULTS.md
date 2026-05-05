# PAR-ARK Results

Updated: 2026-05-05T22:18:27Z

## Scope

This file records the completed Stage A, Stage B1, and Stage B2 results for the local PAR-ARK workflow.

- Workspace: `/home/ubuntu/par_ark_workspace`
- ARK workspace: `/home/ubuntu/par_ark_workspace/ark`
- Run state/logs: `/home/ubuntu/par_ark_workspace/run_state`
- Table artifact from B1: `/home/ubuntu/par_ark_workspace/ark/paper_tables/par_ark_tables.md`
- GPU constraint used: 2 project GPUs max, no CPU offload
- Current server state after cleanup: no PAR-ARK vLLM server is running; GPUs 1, 2, and 3 are free

## Stage A: Qwen3-14B Validation Ablation Grid

Stage A completed successfully at `2026-05-05T13:28:59Z`.

Configuration:

- Model: `Qwen/Qwen3-14B`
- Split: `val`
- Limit: `100` questions per cell
- Graphs: `prime`, `mag`, `amazon`
- Modes: `off`, `profile`, `trace`, `full`
- Step budgets: `12`, `16`
- Total cells: `3 graphs x 4 modes x 2 step budgets = 24`
- Metrics files produced: `24/24`

Important caveat:

- `amazon/full/steps=12` produced `n=99`. All other Stage A cells produced `n=100`.

### Stage A Full Table

| Graph | Mode | Steps | n | Hit@1 | Hit@5 | R@10 | R@20 | R@all | MRR | TimeMean(s) | StepsMean | Global | Neighbor | Zero | Repeat |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| prime | off | 12 | 100 | 0.2100 | 0.3500 | 0.3437 | 0.3489 | 0.3489 | 0.2736 | 20.684 | 3.920 | 0.000 | 0.000 | 0.000 | 0.000 |
| prime | off | 16 | 100 | 0.1600 | 0.3200 | 0.3099 | 0.3112 | 0.3112 | 0.2326 | 20.887 | 3.940 | 0.000 | 0.000 | 0.000 | 0.000 |
| prime | profile | 12 | 100 | 0.1700 | 0.3100 | 0.3033 | 0.3358 | 0.3358 | 0.2295 | 23.721 | 5.210 | 0.000 | 0.000 | 0.000 | 0.000 |
| prime | profile | 16 | 100 | 0.1300 | 0.3600 | 0.3420 | 0.3545 | 0.3545 | 0.2350 | 23.321 | 5.250 | 0.000 | 0.000 | 0.000 | 0.000 |
| prime | trace | 12 | 100 | 0.1400 | 0.2200 | 0.1982 | 0.1982 | 0.1982 | 0.1785 | 19.031 | 5.740 | 2.140 | 1.850 | 1.340 | 0.320 |
| prime | trace | 16 | 100 | 0.1500 | 0.2600 | 0.2262 | 0.2262 | 0.2262 | 0.1957 | 18.712 | 6.160 | 2.260 | 2.130 | 1.620 | 0.490 |
| prime | full | 12 | 100 | 0.1500 | 0.2300 | 0.2070 | 0.2070 | 0.2070 | 0.1885 | 19.864 | 6.390 | 2.420 | 2.250 | 1.880 | 0.420 |
| prime | full | 16 | 100 | 0.1300 | 0.2000 | 0.1908 | 0.1945 | 0.1945 | 0.1619 | 19.479 | 5.770 | 2.130 | 2.230 | 1.860 | 0.370 |
| mag | off | 12 | 100 | 0.3700 | 0.5500 | 0.4741 | 0.4964 | 0.4964 | 0.4394 | 26.316 | 4.110 | 0.000 | 0.000 | 0.000 | 0.000 |
| mag | off | 16 | 100 | 0.3900 | 0.5700 | 0.4812 | 0.5127 | 0.5127 | 0.4683 | 28.070 | 4.130 | 0.000 | 0.000 | 0.000 | 0.000 |
| mag | profile | 12 | 100 | 0.2700 | 0.4400 | 0.3985 | 0.4029 | 0.4029 | 0.3360 | 26.827 | 4.620 | 0.000 | 0.000 | 0.000 | 0.000 |
| mag | profile | 16 | 100 | 0.2300 | 0.4400 | 0.3656 | 0.3850 | 0.3850 | 0.3140 | 25.880 | 4.660 | 0.000 | 0.000 | 0.000 | 0.000 |
| mag | trace | 12 | 100 | 0.2300 | 0.4200 | 0.3445 | 0.3678 | 0.3678 | 0.3069 | 21.233 | 5.360 | 1.710 | 1.780 | 1.010 | 0.100 |
| mag | trace | 16 | 100 | 0.2900 | 0.4800 | 0.3962 | 0.4196 | 0.4196 | 0.3611 | 22.099 | 5.410 | 1.770 | 2.020 | 1.240 | 0.140 |
| mag | full | 12 | 100 | 0.2500 | 0.4200 | 0.3360 | 0.3639 | 0.3639 | 0.3147 | 22.274 | 5.660 | 1.850 | 1.990 | 1.360 | 0.170 |
| mag | full | 16 | 100 | 0.2500 | 0.4400 | 0.3665 | 0.3835 | 0.3835 | 0.3234 | 22.404 | 5.710 | 1.870 | 2.080 | 1.350 | 0.220 |
| amazon | off | 12 | 100 | 0.4200 | 0.6300 | 0.4118 | 0.4303 | 0.4303 | 0.5130 | 30.823 | 3.070 | 0.000 | 0.000 | 0.000 | 0.000 |
| amazon | off | 16 | 100 | 0.4200 | 0.6300 | 0.4129 | 0.4338 | 0.4338 | 0.5165 | 33.189 | 3.050 | 0.000 | 0.000 | 0.000 | 0.000 |
| amazon | profile | 12 | 100 | 0.4100 | 0.6100 | 0.3963 | 0.4147 | 0.4155 | 0.4878 | 33.397 | 3.330 | 0.000 | 0.000 | 0.000 | 0.000 |
| amazon | profile | 16 | 100 | 0.4000 | 0.6100 | 0.4000 | 0.4149 | 0.4149 | 0.4930 | 31.140 | 3.340 | 0.000 | 0.000 | 0.000 | 0.000 |
| amazon | trace | 12 | 100 | 0.3300 | 0.4900 | 0.2824 | 0.2859 | 0.2859 | 0.3979 | 22.983 | 5.260 | 1.760 | 1.530 | 1.320 | 0.210 |
| amazon | trace | 16 | 100 | 0.3800 | 0.5100 | 0.3083 | 0.3128 | 0.3128 | 0.4352 | 19.172 | 5.190 | 1.690 | 1.870 | 1.590 | 0.150 |
| amazon | full | 12 | 99 | 0.3737 | 0.5354 | 0.3266 | 0.3398 | 0.3398 | 0.4392 | 21.725 | 5.242 | 1.808 | 1.747 | 1.434 | 0.323 |
| amazon | full | 16 | 100 | 0.3900 | 0.5300 | 0.3152 | 0.3214 | 0.3214 | 0.4456 | 24.313 | 5.080 | 1.710 | 2.520 | 2.230 | 0.110 |

### Stage A Averages Across Graphs

| Mode | Steps | Avg Hit@1 | Avg Hit@5 | Avg R@20 | Avg MRR | Avg Time(s) | Avg Steps |
|---|---:|---:|---:|---:|---:|---:|---:|
| off | 12 | 0.3333 | 0.5100 | 0.4252 | 0.4087 | 25.941 | 3.700 |
| off | 16 | 0.3233 | 0.5067 | 0.4192 | 0.4058 | 27.382 | 3.707 |
| profile | 12 | 0.2833 | 0.4533 | 0.3845 | 0.3511 | 27.982 | 4.387 |
| profile | 16 | 0.2533 | 0.4700 | 0.3848 | 0.3473 | 26.780 | 4.417 |
| trace | 12 | 0.2333 | 0.3767 | 0.2840 | 0.2944 | 21.082 | 5.453 |
| trace | 16 | 0.2733 | 0.4167 | 0.3195 | 0.3307 | 19.994 | 5.587 |
| full | 12 | 0.2579 | 0.3951 | 0.3036 | 0.3141 | 21.288 | 5.764 |
| full | 16 | 0.2567 | 0.3900 | 0.2998 | 0.3103 | 22.065 | 5.520 |

### Stage A Best Configurations

| Graph | Best MRR | Best Hit@5 | Best R@20 |
|---|---|---|---|
| prime | off steps=12 MRR=0.2736 | profile steps=16 Hit@5=0.3600 | profile steps=16 R@20=0.3545 |
| mag | off steps=16 MRR=0.4683 | off steps=16 Hit@5=0.5700 | off steps=16 R@20=0.5127 |
| amazon | off steps=16 MRR=0.5165 | off steps=12 Hit@5=0.6300 | off steps=16 R@20=0.4338 |

### Stage A Takeaways

- The `off` baseline is the strongest average configuration by MRR, Hit@5, and R@20.
- Increasing `off` from 12 to 16 steps did not improve the average result. It helped MAG and Amazon slightly, but PRIME got worse.
- `profile` preserved some recall on PRIME and Amazon but trailed `off` in average MRR.
- `trace` and `full` produced the PAR action statistics we need for analysis, but both underperformed `off` on average.
- The full PAR-ARK mechanism is not yet competitive with the local/off baseline under this exact Qwen3-14B validation setup.

## Stage B1: Table Collection And Selection

Stage B1 completed successfully at `2026-05-05T15:37:28Z`.

Outputs:

- Paper table artifact: `/home/ubuntu/par_ark_workspace/ark/paper_tables/par_ark_tables.md`
- Local summary artifact: `STAGE_B_SUMMARY.md`

Decision from B1:

- Keep `off` as the accuracy/control baseline.
- Keep `full` as the PAR-ARK candidate for final evidence, because it is the complete PAR intervention even though Stage A validation did not favor it.
- Use `max_steps=16` for the off-vs-full final-test comparison, matching the existing final-test script and keeping a fixed depth across graphs.

## Stage B2: Qwen3-30B-A3B Pilot

Stage B2 completed successfully at `2026-05-05T17:17:45Z`.

Configuration:

- Model: `Qwen/Qwen3-30B-A3B-Instruct-2507`
- Serve stage: `09_serve_qwen3_30b_a3b_tp2`
- Pilot stage: `17_run_stage_b2_30b_pilot`
- GPUs: `1,2`
- Tensor parallel: `2`
- CPU offload: not used
- Split: `test`
- Limit: `50` questions per cell
- Graphs: `prime`, `mag`, `amazon`
- Modes: `off`, `full`
- Max steps: `16`
- Total cells: `6`
- Metrics files produced: `6/6`

Operational notes:

- 30B-A3B server became healthy on `/v1/models` at `2026-05-05T15:50:49Z`.
- First startup included downloading about 56.87 GiB of weights and compiling/warming vLLM.
- One context-window error occurred in `prime/off`: one prompt exceeded 32,768 tokens by at least one token. The run handled the error, checkpointed progress, and continued.
- The `prime/off` and `mag/off` pilot cells therefore report `n=49`; the other four B2 cells report `n=50`.
- After B2, the 30B server was stopped at `2026-05-05T22:18:27Z`; no PAR-ARK vLLM process remains running.

### Stage B2 Full Table

| Graph | Mode | n | Hit@1 | Hit@5 | R@10 | R@20 | R@all | MRR | TimeMean(s) | StepsMean | Global | Neighbor | Zero | Repeat |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| prime | off | 49 | 0.3061 | 0.4082 | 0.3748 | 0.3952 | 0.3952 | 0.3502 | 9.435 | 5.714 | 0.000 | 0.000 | 0.000 | 0.000 |
| prime | full | 50 | 0.2200 | 0.3200 | 0.2651 | 0.3051 | 0.3051 | 0.2670 | 7.444 | 8.920 | 4.700 | 6.400 | 5.680 | 1.940 |
| mag | off | 49 | 0.7551 | 0.8776 | 0.7219 | 0.7464 | 0.7668 | 0.8105 | 12.483 | 4.551 | 0.000 | 0.000 | 0.000 | 0.000 |
| mag | full | 50 | 0.4400 | 0.5400 | 0.4608 | 0.4608 | 0.4608 | 0.4797 | 6.951 | 6.140 | 2.580 | 5.200 | 2.920 | 0.460 |
| amazon | off | 50 | 0.5800 | 0.7800 | 0.4545 | 0.4592 | 0.4592 | 0.6600 | 10.251 | 4.120 | 0.000 | 0.000 | 0.000 | 0.000 |
| amazon | full | 50 | 0.4400 | 0.6400 | 0.3798 | 0.3798 | 0.3798 | 0.5150 | 6.333 | 6.520 | 2.740 | 4.940 | 3.540 | 0.720 |

### Stage B2 Full Minus Off Deltas

| Graph | Delta full-off Hit@1 | Delta Hit@5 | Delta R@20 | Delta MRR | Delta Time(s) |
|---|---:|---:|---:|---:|---:|
| prime | -0.0861 | -0.0882 | -0.0901 | -0.0832 | -1.991 |
| mag | -0.3151 | -0.3376 | -0.2856 | -0.3308 | -5.532 |
| amazon | -0.1400 | -0.1400 | -0.0794 | -0.1450 | -3.918 |

### Stage B2 Takeaways

- The 30B pilot repeats the Stage A pattern: `off` beats `full` on every graph by MRR, Hit@5, and R@20.
- The gap is largest on MAG, where `full` loses 0.3308 MRR and 0.3376 Hit@5 relative to `off`.
- `full` is faster per question in the pilot, but that speed comes with substantially lower accuracy.
- `full` produces meaningful action-count telemetry: global searches, neighborhood searches, zero-result calls, and repeated calls. This is useful for mechanism analysis, but it did not translate into better retrieval quality here.
- For a paper-quality claim, the current evidence supports reporting PAR-ARK as an interpretable/action-traced variant that underperforms the local/off baseline in these settings, unless the method is modified before final full-test runs.

## Overall Takeaways After Stage A, B1, And B2

- The infrastructure is working: detached stages, logs, progress JSON, checkpoints, resumability, and GPU-limited serving all worked end to end.
- Qwen3-14B validation and Qwen3-30B-A3B pilot agree qualitatively: `off` is the accuracy winner.
- The complete PAR-ARK `full` mode currently has worse accuracy than `off` on all evaluated graphs in the 30B pilot.
- Before spending multiple days on full Stage C, the method should be reconsidered or Stage C should be reframed as a diagnostic/negative-result run rather than an expected win.
- If Stage C is still run unchanged, the highest-value comparison remains `off` vs `full` at `max_steps=16`, because it directly measures the current baseline/control against the complete PAR-ARK intervention.
