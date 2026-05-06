# PAR-ARK Results

Updated: 2026-05-06T07:15:00Z

## Scope

This file records the completed end-to-end local PAR-ARK deadline-rescue workflow through Stage G.

- Workspace: `/home/ubuntu/par_ark_workspace`
- ARK workspace: `/home/ubuntu/par_ark_workspace/ark`
- Run state/logs: `/home/ubuntu/par_ark_workspace/run_state`
- Table artifact from B1: `/home/ubuntu/par_ark_workspace/ark/paper_tables/par_ark_tables.md`
- Final deadline tables: `/home/ubuntu/par_ark_workspace/ark/paper_tables/deadline_all_tables.md`
- Final paired diagnostics: `/home/ubuntu/par_ark_workspace/ark/paper_tables/{prime,mag,amazon}_deadline_pair_diagnostics.md`
- GPU constraint used initially: 2 L40S project GPUs, no CPU offload
- Final acceleration path: two TP2 Qwen3-30B-A3B replicas on 4 L40S GPUs, ports `8000` and `8100`
- Current server state at final status check: both 30B vLLM servers healthy and loaded, GPUs idle at 0% utilization but holding model memory

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

## Deadline Rescue Pivot

After Stage A/B showed that `full` did not beat `off`, the workflow pivoted from a positive PAR-ARK improvement paper to a failure/diagnostic paper:

**When Adaptive Knowledge-Graph Retrieval Fails: Trace Diagnostics for Local LLM Agents on STaRK**.

The evidence target changed to:

- Stage E: larger Qwen3-30B-A3B `LIMIT=300` off-vs-full test subset.
- Stage F: budget-fix probe to test whether stricter trace budgets reduce harm.
- Stage G: paired diagnostics explaining when and how full trace/control fails.

The core paper claim supported by completed results is not that PAR-ARK beats ARK/SOTA. The supported claim is that local adaptive KG retrieval can fail under trace/control-heavy profiles, and that trace statistics reveal mechanisms such as repeated calls and zero-result retrieval.

## Stage E: Qwen3-30B-A3B Main Deadline Subset

Stage E completed successfully in sharded form at `2026-05-06T02:23:54Z`.

Configuration:

- Model: `Qwen/Qwen3-30B-A3B-Instruct-2507`
- Split: `test`
- Limit: `300` questions per graph/mode cell
- Max steps: `16`
- Graphs: `prime`, `mag`, `amazon`
- Modes: `off`, `full`
- Total target workload: `3 graphs x 2 modes x 300 = 1800` question-runs
- Metrics files produced: `6/6`
- CPU offload: not used
- Context length: `32768`

Execution details:

- Initial serial Stage E started at `2026-05-05T22:50:16Z` on the known-working TP2 server at port `8000`.
- At user request, three idle GPU0 tutor workers were killed and a second TP2 server was prepared.
- First second-replica attempt failed at `2026-05-05T23:04:03Z` because port `8001` was already in use by an existing vLLM worker side-port.
- The second replica was relaunched on GPUs `0,3` with port `8100` and became healthy at `2026-05-05T23:07:41Z`.
- The serial Stage E client was stopped at `2026-05-05T23:07:58Z`; already written question JSONs were retained.
- Shard A started at `2026-05-05T23:08:20Z` on port `8000` with cells `prime:off prime:full mag:full amazon:off amazon:full`, resuming `prime/off` by skipping existing question logs.
- Shard B started at `2026-05-05T23:08:20Z` on port `8100` with cell `mag:off`.
- Shard B completed at `2026-05-06T00:09:41Z`.
- Shard A completed at `2026-05-06T02:23:54Z`.

Stage E wall-clock notes:

- Initial serial run before sharding: about `18m`.
- Sharded Stage E after relaunch: about `3h15m`.
- Overall Stage E elapsed from first launch to final shard completion: about `3h34m`.
- The two-replica setup materially reduced the projected deadline runtime compared with a serial two-GPU run.

### Stage E Full Table

| Graph | Mode | n | Hit@1 | Hit@5 | R@20 | MRR | TimeMean(s) | StepsMean | Global | Neighbor | Zero | Repeat | Progress caveat |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|
| prime | off | 290 | 0.2966 | 0.4207 | 0.3681 | 0.3499 | 10.165 | 5.845 | 0.000 | 0.000 | 0.000 | 0.000 | 10/300 errors, 3.3% |
| prime | full | 300 | 0.2400 | 0.3600 | 0.3297 | 0.2880 | 7.498 | 8.287 | 4.197 | 5.670 | 4.560 | 1.730 | complete |
| mag | off | 299 | 0.7224 | 0.8328 | 0.7483 | 0.7711 | 12.179 | 4.294 | 0.000 | 0.000 | 0.000 | 0.000 | 1/300 error, 0.3% |
| mag | full | 300 | 0.4233 | 0.5900 | 0.5006 | 0.4974 | 7.570 | 5.887 | 2.427 | 5.030 | 2.283 | 0.663 | complete |
| amazon | off | 296 | 0.5439 | 0.7128 | 0.4557 | 0.6152 | 9.846 | 4.240 | 0.000 | 0.000 | 0.000 | 0.000 | 4/300 errors, 1.3% |
| amazon | full | 300 | 0.5033 | 0.6567 | 0.3607 | 0.5714 | 6.367 | 6.153 | 2.433 | 5.510 | 3.960 | 0.653 | complete |

### Stage E Full Minus Off Deltas

| Graph | Delta Hit@1 | Delta Hit@5 | Delta R@20 | Delta MRR | Delta Time(s) |
|---|---:|---:|---:|---:|---:|
| prime | -0.0566 | -0.0607 | -0.0384 | -0.0619 | -2.667 |
| mag | -0.2991 | -0.2428 | -0.2477 | -0.2737 | -4.609 |
| amazon | -0.0406 | -0.0561 | -0.0950 | -0.0438 | -3.479 |

### Stage E Takeaways

- The larger `LIMIT=300` subset confirms the pilot pattern: `off` beats `full` on all three graphs by MRR, Hit@5, and R@20.
- The largest failure remains MAG: `full` loses 0.2737 MRR and 0.2477 R@20 against `off`.
- `full` is faster per question in all three Stage E cells, but the speed is not enough to compensate for the accuracy loss.
- `full` creates rich trace telemetry. This is useful for diagnostics, but it does not improve retrieval quality under this configuration.
- Off-mode context errors are operational caveats, not dominant failures: prime/off 3.3%, mag/off 0.3%, amazon/off 1.3%; all stayed below the 5% stop threshold.
- Stage E is the central evidence for the failure-mode paper.

## Stage F: Budget-Fix Probe

Stage F completed successfully at `2026-05-06T02:46:45Z`.

Configuration:

- Model: `Qwen/Qwen3-30B-A3B-Instruct-2507`
- Split: `test`
- Limit: `150`
- Mode: `full` only
- Max steps: `8`
- Max global searches: `2`
- Max neighborhood searches: `3`
- Max observation chars: `2500`
- Max answers: `10`
- Graphs: `prime`, `mag`, `amazon`
- Metrics files produced: `3/3`

Execution details:

- Supervisor launched Stage F after Stage E reached `6/6` metrics.
- Shard A started at `2026-05-06T02:24:14Z` on port `8000` with graphs `prime amazon`.
- Shard B started at `2026-05-06T02:24:14Z` on port `8100` with graph `mag`.
- Shard B completed at `2026-05-06T02:37:08Z`.
- Shard A completed at `2026-05-06T02:46:45Z`.
- Stage F sharded elapsed time: about `22m31s`.

### Stage F Budget-Fix Table

| Graph | n | Hit@1 | Hit@5 | R@20 | MRR | TimeMean(s) | StepsMean | Global | Neighbor | Zero | Repeat |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| prime | 150 | 0.1200 | 0.2067 | 0.1857 | 0.1556 | 4.944 | 5.493 | 2.580 | 3.440 | 2.780 | 0.487 |
| mag | 150 | 0.2800 | 0.4867 | 0.4020 | 0.3727 | 5.091 | 4.860 | 1.847 | 3.793 | 1.587 | 0.133 |
| amazon | 150 | 0.4133 | 0.5000 | 0.2879 | 0.4511 | 3.932 | 4.927 | 1.807 | 3.347 | 2.227 | 0.193 |

### Stage F Takeaways

- The budget-fix probe reduces repeated calls versus Stage E full-mode telemetry.
- It also reduces latency substantially.
- It does not rescue accuracy. On all three graphs, budget-fix MRR is below Stage E full and far below Stage E off.
- This should be reported as a mitigation/trade-off probe, not as a tuned final method.
- The paper should phrase Stage F as: stricter budgets reduce some trace pathologies and runtime, but can also truncate useful retrieval depth and further harm accuracy.

## Stage G: Paired Diagnostics And Tables

Stage G completed successfully inside the supervisor at `2026-05-06T02:49:15Z`.

Inputs:

- Stage E off logs for each graph.
- Stage E full logs for each graph.

Outputs:

- `/home/ubuntu/par_ark_workspace/ark/paper_tables/prime_deadline_pair_diagnostics.md`
- `/home/ubuntu/par_ark_workspace/ark/paper_tables/prime_deadline_pair_diagnostics.json`
- `/home/ubuntu/par_ark_workspace/ark/paper_tables/mag_deadline_pair_diagnostics.md`
- `/home/ubuntu/par_ark_workspace/ark/paper_tables/mag_deadline_pair_diagnostics.json`
- `/home/ubuntu/par_ark_workspace/ark/paper_tables/amazon_deadline_pair_diagnostics.md`
- `/home/ubuntu/par_ark_workspace/ark/paper_tables/amazon_deadline_pair_diagnostics.json`
- `/home/ubuntu/par_ark_workspace/ark/paper_tables/deadline_all_tables.md`

### Stage G Paired Main Metrics

| Graph | paired_n | off MRR | full MRR | Delta MRR | off Hit@5 | full Hit@5 | Delta Hit@5 | off R@20 | full R@20 | Delta R@20 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| prime | 291 | 0.3487 | 0.2834 | -0.0653 | 0.4192 | 0.3540 | -0.0653 | 0.3668 | 0.3247 | -0.0421 |
| mag | 300 | 0.7686 | 0.4974 | -0.2711 | 0.8300 | 0.5900 | -0.2400 | 0.7458 | 0.5006 | -0.2452 |
| amazon | 297 | 0.6131 | 0.5705 | -0.0426 | 0.7104 | 0.6566 | -0.0539 | 0.4542 | 0.3631 | -0.0911 |

### Stage G Win/Tie/Loss

| Graph | MRR wins | MRR ties | MRR losses | Hit@1 wins | Hit@1 ties | Hit@1 losses |
|---|---:|---:|---:|---:|---:|---:|
| prime | 38 | 192 | 61 | 21 | 232 | 38 |
| mag | 29 | 138 | 133 | 21 | 169 | 110 |
| amazon | 43 | 190 | 64 | 25 | 235 | 37 |

### Stage G Trace Mechanism Notes

| Graph | Global | Neighbor | Zero-result | Repeated | Events | Steps | Time(s) |
|---|---:|---:|---:|---:|---:|---:|---:|
| prime | 4.1478 | 5.7010 | 4.6151 | 1.6564 | 11.8179 | 8.2577 | 7.4768 |
| mag | 2.4133 | 5.0200 | 2.2767 | 0.6633 | 9.8333 | 5.8667 | 7.5468 |
| amazon | 2.4040 | 5.4815 | 3.9293 | 0.6364 | 10.3131 | 6.1111 | 6.3344 |

Conditional diagnostic highlights:

- PRIME repeated calls are strongly associated with worse full-minus-off MRR: repeat=0 mean delta `-0.0023`, repeat>=1 mean delta `-0.1228`.
- PRIME zero-result events also separate behavior: zero=0 mean delta `+0.0380`, zero>=1 mean delta `-0.0776`.
- MAG repeated calls are especially damaging: repeat=0 mean delta `-0.2292`, repeat>=1 mean delta `-0.3826`.
- MAG zero-result events are also worse: zero=0 mean delta `-0.1951`, zero>=1 mean delta `-0.3075`.
- AMAZON has a more nuanced zero-result pattern, but `full` still loses overall; repeat>=1 is slightly worse than repeat=0.

Oracle/fusion caveat:

- Diagnostics include oracle upper bounds and exploratory fusion sweeps.
- These are diagnostic only. They must not be reported as deployable methods unless a routing/fusion rule is fixed on validation and then evaluated on held-out test.

## End-To-End Status After Stage G

Completed:

- Stage 0/preflight/server setup.
- Stage A validation grid.
- Stage B1 table collection and selection.
- Stage B2 30B pilot.
- Stage E deadline subset.
- Stage F budget-fix probe.
- Stage G paired diagnostics and regenerated summary tables.

Not run by design:

- Full multi-day Stage C.
- Stage D reranking.
- Any CPU-offloaded run.

Failed or interrupted experiments preserved:

- `20_serve_qwen3_30b_a3b_tp2_replica_b` failed on port `8001` because the existing vLLM worker owned `*:8001`; the successful retry used port `8100`.
- `18_run_stage_e_30b_subset` serial client was intentionally stopped after partial progress to relaunch with two TP2 shards. Its partial question logs were reused by skip-existing resume.
- Context-window errors were recorded in Stage A, Stage B2, and Stage E. These were handled by the runner and preserved in logs/progress; all Stage E off-cell error rates stayed under the operational 5% stop threshold.

Final paper-level takeaway:

- The completed evidence supports a diagnostic failure-mode paper, not a SOTA/improvement paper.
- Across Qwen3-14B validation, Qwen3-30B pilot, and Qwen3-30B `LIMIT=300` subset, `off` consistently beats `full`.
- Full trace/control creates interpretable telemetry and exposes failure mechanisms, but it does not improve retrieval in the completed local setup.
- Budget fixing reduces trace cost and repeated-call rates but does not repair accuracy.

## Results Bundle

An exhaustive local results bundle was created after documentation updates:

- Folder: `/home/ubuntu/nachiket/Ablations/PStuff/PAR-ARK/results/par_ark_deadline_results_2026_05_06_0715`
- Zip archive: `/home/ubuntu/nachiket/Ablations/PStuff/PAR-ARK/results/par_ark_deadline_results_2026_05_06_0715.zip`
- Zip verification: `unzip -tq` passed with no compressed-data errors.
- Approximate zip size: `28 MB`

Bundle contents include:

- Updated `RUNBOOK.md`, updated `RESULTS.md`, Stage B summary, rescue plan, README, and paper outline.
- All paper tables and paired diagnostics.
- Generated CSV/JSON summaries for metrics and progress files.
- Raw experiment artifacts copied from `/home/ubuntu/par_ark_workspace/ark/data/experiments`, including per-question trace/result JSONs.
- Detached run logs, status files, heartbeats, env snapshots, PID files, command wrappers, and checkpoints from `/home/ubuntu/par_ark_workspace/run_state`.
- Repo runtime scripts and the full deadline rescue package.
- Final server health snapshots for vLLM ports `8000` and `8100`.
- Manifest and SHA256 checksums.
