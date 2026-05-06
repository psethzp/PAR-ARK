# PAR-ARK Runbook

This runbook is the live record for the local PAR-ARK workflow. Runtime scripts append UTC timestamped events here and write machine-readable status under `$WORKDIR/run_state/status`.

## Local Constraints

- Use only 2 GPUs for PAR-ARK jobs.
- Default 1-GPU runs use `PARARK_GPU_1=1`.
- Default 2-GPU runs use `PARARK_GPUS_2=1,2`.
- Keep project working data under `$WORKDIR=$HOME/par_ark_workspace`.
- Keep Hugging Face and model caches under `$WORKDIR/cache`.
- Treat `PARARK_DISK_BUDGET_GB=700` as the working budget.
- Do not use CPU offloading.
- Prefer BF16 and lower `max_model_len`/batch/concurrency if memory is tight.

## How To Monitor

- Overall status: `bash scripts/14_status.sh`
- Tail a stage: `bash scripts/15_tail_stage.sh <stage-name>`
- Detached run pattern: `bash scripts/16_run_detached.sh <stage-name> bash scripts/<script>.sh`
- Long experiment progress files live inside each ARK experiment output directory:
  - `latest_progress.json`
  - `progress.jsonl`
  - per-question JSON logs, which act as resume checkpoints

## Event Log

- 2026-05-04T00:00:00Z Initialized runbook for the current-env resumable workflow.
- 2026-05-04T18:56:14Z [13_preflight_current_env] RUNNING: checking local constraints
- 2026-05-04T18:56:14Z [disk] WORKDIR usage 1GB within 700GB budget
- 2026-05-04T18:56:15Z [13_preflight_current_env] checkpoint: preflight passed
- 2026-05-04T18:56:15Z [13_preflight_current_env] SUCCEEDED: current environment is usable
- 2026-05-04T18:56:18Z [00_create_workspace] RUNNING: creating ARK workspace
- 2026-05-04T18:56:18Z [disk] WORKDIR usage 1GB within 700GB budget
- 2026-05-04T18:56:19Z [00_create_workspace] checkpoint: ARK commit 8d3191b9de1ebf05a69ff88821edd08fc050760b
- 2026-05-04T18:56:19Z [00_create_workspace] SUCCEEDED: Workspace ready at /home/ubuntu/par_ark_workspace/ark
- 2026-05-04T18:56:26Z [01_setup_env] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/01_setup_env.detached.log
- 2026-05-04T18:56:26Z [01_setup_env] DETACHED: pid=2745301 log=/home/ubuntu/par_ark_workspace/run_state/logs/01_setup_env.detached.log
- 2026-05-04T18:56:26Z [01_setup_env] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/01_setup_env.log
- 2026-05-04T18:57:24Z [01_setup_env] FAILED: first detached wrapper exited before command output; fixed detacher and relaunching
- 2026-05-04T18:57:26Z [01_setup_env] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/01_setup_env.detached.log
- 2026-05-04T18:57:26Z [01_setup_env] DETACHED: pid=2745839 log=/home/ubuntu/par_ark_workspace/run_state/logs/01_setup_env.detached.log
- 2026-05-04T18:57:26Z [01_setup_env] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/01_setup_env.log
- 2026-05-04T18:57:50Z [01_setup_env] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/01_setup_env.log
- 2026-05-04T18:57:50Z [01_setup_env] RUNNING: installing uv/vLLM/stark dependencies
- 2026-05-04T18:57:50Z [disk] WORKDIR usage 1GB within 700GB budget
- 2026-05-04T18:59:07Z [01_setup_env] checkpoint: environment installed with UV_PYTHON=3.11
- 2026-05-04T18:59:07Z [01_setup_env] SUCCEEDED: Environment installed
- 2026-05-04T18:59:07Z [01_setup_env] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/01_setup_env.log
- 2026-05-04T18:59:07Z [01_setup_env] checkpoint: completed successfully
- 2026-05-04T18:59:41Z [01_setup_env] SUCCEEDED: environment verified after PATH and numpy<2 pin
- 2026-05-04T19:00:08Z [01_setup_env] SUCCEEDED: environment verified with UV_NO_SYNC=1 and numpy<2
- 2026-05-04T19:00:20Z [test_detached] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/test_detached.detached.log
- 2026-05-04T19:00:20Z [test_detached] DETACHED: pid=2750123 log=/home/ubuntu/par_ark_workspace/run_state/logs/test_detached.detached.log
- 2026-05-04T19:00:20Z [test_detached] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/test_detached.log
- 2026-05-04T19:00:21Z [test_detached] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/test_detached.log
- 2026-05-04T19:00:21Z [test_detached] checkpoint: completed successfully
- 2026-05-04T19:00:28Z [02_get_data_and_preprocess] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/02_get_data_and_preprocess.detached.log
- 2026-05-04T19:00:28Z [02_get_data_and_preprocess] DETACHED: pid=2750281 log=/home/ubuntu/par_ark_workspace/run_state/logs/02_get_data_and_preprocess.detached.log
- 2026-05-04T19:00:28Z [02_get_data_and_preprocess] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/02_get_data_and_preprocess.log
- 2026-05-04T19:01:16Z [02_get_data_and_preprocess] FAILED: detached launch stale before heartbeat; patched detacher to setsid nohup
- 2026-05-04T19:01:22Z [test_detached_long] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/test_detached_long.detached.log
- 2026-05-04T19:01:22Z [test_detached_long] DETACHED: pid=2750827 log=/home/ubuntu/par_ark_workspace/run_state/logs/test_detached_long.detached.log
- 2026-05-04T19:01:22Z [test_detached_long] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/test_detached_long.log
- 2026-05-04T19:01:30Z [test_detached_long] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/test_detached_long.log
- 2026-05-04T19:01:30Z [test_detached_long] checkpoint: completed successfully
- 2026-05-04T19:01:40Z [02_get_data_and_preprocess] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/02_get_data_and_preprocess.detached.log
- 2026-05-04T19:01:40Z [02_get_data_and_preprocess] DETACHED: pid=2751148 log=/home/ubuntu/par_ark_workspace/run_state/logs/02_get_data_and_preprocess.detached.log
- 2026-05-04T19:01:40Z [02_get_data_and_preprocess] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/02_get_data_and_preprocess.log
- 2026-05-04T19:01:40Z [02_get_data_and_preprocess] RUNNING: downloading STaRK data and checking ARK layout
- 2026-05-04T19:01:41Z [disk] WORKDIR usage 9GB within 700GB budget
- 2026-05-04T19:05:26Z [02_get_data_and_preprocess] checkpoint: stark_qa processed cache warmed
- 2026-05-04T19:05:26Z [02_get_data_and_preprocess] FAILED: rc=3 log=/home/ubuntu/par_ark_workspace/run_state/logs/02_get_data_and_preprocess.log
- 2026-05-04T19:07:05Z [02_get_data_and_preprocess] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/02_get_data_and_preprocess.detached.log
- 2026-05-04T19:07:05Z [02_get_data_and_preprocess] DETACHED: pid=2755420 log=/home/ubuntu/par_ark_workspace/run_state/logs/02_get_data_and_preprocess.detached.log
- 2026-05-04T19:07:05Z [02_get_data_and_preprocess] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/02_get_data_and_preprocess.log
- 2026-05-04T19:07:05Z [02_get_data_and_preprocess] RUNNING: downloading STaRK data and checking ARK layout
- 2026-05-04T19:07:05Z [disk] WORKDIR usage 26GB within 700GB budget
- 2026-05-04T19:08:58Z [02_get_data_and_preprocess] checkpoint: stark_qa processed cache warmed
- 2026-05-04T19:08:58Z [02_get_data_and_preprocess] checkpoint: linked STaRK snapshot into ARK raw_graphs and qa
- 2026-05-04T19:09:19Z [02_get_data_and_preprocess] checkpoint: completed preprocessing/prime_to_parquet.py
- 2026-05-04T19:09:19Z [disk] WORKDIR usage 26GB within 700GB budget
- 2026-05-04T19:10:51Z [02_get_data_and_preprocess] checkpoint: completed preprocessing/mag_to_parquet.py
- 2026-05-04T19:10:51Z [disk] WORKDIR usage 26GB within 700GB budget
- 2026-05-04T19:17:30Z [02_get_data_and_preprocess] checkpoint: completed preprocessing/amazon_to_parquet.py
- 2026-05-04T19:17:30Z [disk] WORKDIR usage 27GB within 700GB budget
- 2026-05-04T19:17:30Z [disk] WORKDIR usage 27GB within 700GB budget
- 2026-05-04T19:17:30Z [02_get_data_and_preprocess] checkpoint: data layout verified
- 2026-05-04T19:17:30Z [02_get_data_and_preprocess] SUCCEEDED: STaRK data ready
- 2026-05-04T19:17:30Z [02_get_data_and_preprocess] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/02_get_data_and_preprocess.log
- 2026-05-04T19:17:30Z [02_get_data_and_preprocess] checkpoint: completed successfully
- 2026-05-04T19:18:31Z [03_apply_overlay] RUNNING: applying PAR-ARK overlay
- 2026-05-04T19:18:31Z [03_apply_overlay] checkpoint: overlay applied and compiled
- 2026-05-04T19:18:31Z [03_apply_overlay] SUCCEEDED: overlay ready
- 2026-05-04T19:18:45Z [04_serve_qwen3_8b_1gpu] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/04_serve_qwen3_8b_1gpu.detached.log
- 2026-05-04T19:18:45Z [04_serve_qwen3_8b_1gpu] DETACHED: pid=2759491 log=/home/ubuntu/par_ark_workspace/run_state/logs/04_serve_qwen3_8b_1gpu.detached.log
- 2026-05-04T19:18:45Z [04_serve_qwen3_8b_1gpu] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/04_serve_qwen3_8b_1gpu.log
- 2026-05-04T19:18:45Z [04_serve_qwen3_8b_1gpu] RUNNING: starting vLLM Qwen3-8B on GPU 1
- 2026-05-04T19:18:46Z [disk] WORKDIR usage 27GB within 700GB budget
- 2026-05-04T19:18:46Z [04_serve_qwen3_8b_1gpu] checkpoint: launching vLLM on CUDA_VISIBLE_DEVICES=1
- 2026-05-04T19:23:58Z [05_smoke_prime] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/05_smoke_prime.detached.log
- 2026-05-04T19:23:58Z [05_smoke_prime] DETACHED: pid=2762222 log=/home/ubuntu/par_ark_workspace/run_state/logs/05_smoke_prime.detached.log
- 2026-05-04T19:23:58Z [05_smoke_prime] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/05_smoke_prime.log
- 2026-05-04T19:23:58Z [05_smoke_prime] RUNNING: PRIME smoke test
- 2026-05-04T19:33:05Z [05_smoke_prime] checkpoint: smoke generation completed
- 2026-05-04T19:33:05Z [05_smoke_prime] checkpoint: smoke eval completed
- 2026-05-04T19:33:05Z [05_smoke_prime] SUCCEEDED: smoke run complete
- 2026-05-04T19:33:05Z [05_smoke_prime] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/05_smoke_prime.log
- 2026-05-04T19:33:05Z [05_smoke_prime] checkpoint: completed successfully
- 2026-05-04T19:35:19Z [03_apply_overlay] RUNNING: applying PAR-ARK overlay
- 2026-05-04T19:35:19Z [03_apply_overlay] checkpoint: overlay applied and compiled
- 2026-05-04T19:35:19Z [03_apply_overlay] SUCCEEDED: overlay ready
- 2026-05-04T19:35:34Z [05_smoke_prime] SUCCEEDED: smoke complete after eval fix: n=20 Hit@1=0.2 MRR=0.2417
- 2026-05-04T19:35:34Z [05_smoke_prime] checkpoint: metrics_summary.json corrected to ignore progress files
- 2026-05-04T21:02:42Z [06_stop_vllm] RUNNING: stopping vLLM processes
- 2026-05-04T21:02:45Z [04_serve_qwen3_8b_1gpu] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/04_serve_qwen3_8b_1gpu.log
- 2026-05-04T21:02:45Z [04_serve_qwen3_8b_1gpu] checkpoint: completed successfully
- 2026-05-04T21:02:48Z [06_stop_vllm] checkpoint: vLLM stop attempted
- 2026-05-04T21:02:48Z [06_stop_vllm] SUCCEEDED: vLLM stop attempted
- 2026-05-04T21:06:44Z [06_stop_vllm] RUNNING: stopping vLLM processes
- 2026-05-04T21:06:50Z [06_stop_vllm] checkpoint: vLLM stop attempted
- 2026-05-04T21:06:50Z [06_stop_vllm] SUCCEEDED: vLLM stop attempted
- 2026-05-04T21:06:50Z [07_serve_qwen3_14b_1gpu] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/07_serve_qwen3_14b_1gpu.detached.log
- 2026-05-04T21:06:50Z [07_serve_qwen3_14b_1gpu] DETACHED: pid=2790736 log=/home/ubuntu/par_ark_workspace/run_state/logs/07_serve_qwen3_14b_1gpu.detached.log
- 2026-05-04T21:06:50Z [07_serve_qwen3_14b_1gpu] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/07_serve_qwen3_14b_1gpu.log
- 2026-05-04T21:06:50Z [07_serve_qwen3_14b_1gpu] RUNNING: starting vLLM Qwen3-14B on GPU 1
- 2026-05-04T21:06:50Z [disk] WORKDIR usage 43GB within 700GB budget
- 2026-05-04T21:06:50Z [07_serve_qwen3_14b_1gpu] checkpoint: launching vLLM on CUDA_VISIBLE_DEVICES=1
- 2026-05-04T21:15:19Z [08_run_val_ablation_grid] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/08_run_val_ablation_grid.detached.log
- 2026-05-04T21:15:19Z [08_run_val_ablation_grid] DETACHED: pid=2793278 log=/home/ubuntu/par_ark_workspace/run_state/logs/08_run_val_ablation_grid.detached.log
- 2026-05-04T21:15:19Z [08_run_val_ablation_grid] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/08_run_val_ablation_grid.log
- 2026-05-04T21:15:19Z [08_run_val_ablation_grid] RUNNING: Qwen3-14B validation ablation grid
- 2026-05-04T21:49:55Z [08_run_val_ablation_grid] checkpoint: generation graph=prime mode=off steps=12
- 2026-05-04T21:49:55Z [08_run_val_ablation_grid] checkpoint: eval graph=prime mode=off steps=12
- 2026-05-04T21:49:56Z [disk] WORKDIR usage 70GB within 700GB budget
- 2026-05-04T22:24:52Z [08_run_val_ablation_grid] checkpoint: generation graph=prime mode=off steps=16
- 2026-05-04T22:24:53Z [08_run_val_ablation_grid] checkpoint: eval graph=prime mode=off steps=16
- 2026-05-04T22:24:53Z [disk] WORKDIR usage 70GB within 700GB budget
- 2026-05-04T23:04:33Z [08_run_val_ablation_grid] checkpoint: generation graph=prime mode=profile steps=12
- 2026-05-04T23:04:33Z [08_run_val_ablation_grid] checkpoint: eval graph=prime mode=profile steps=12
- 2026-05-04T23:04:34Z [disk] WORKDIR usage 70GB within 700GB budget
- 2026-05-04T23:43:33Z [08_run_val_ablation_grid] checkpoint: generation graph=prime mode=profile steps=16
- 2026-05-04T23:43:34Z [08_run_val_ablation_grid] checkpoint: eval graph=prime mode=profile steps=16
- 2026-05-04T23:43:34Z [disk] WORKDIR usage 70GB within 700GB budget
- 2026-05-05T00:15:25Z [08_run_val_ablation_grid] checkpoint: generation graph=prime mode=trace steps=12
- 2026-05-05T00:15:25Z [08_run_val_ablation_grid] checkpoint: eval graph=prime mode=trace steps=12
- 2026-05-05T00:15:26Z [disk] WORKDIR usage 70GB within 700GB budget
- 2026-05-05T00:46:45Z [08_run_val_ablation_grid] checkpoint: generation graph=prime mode=trace steps=16
- 2026-05-05T00:46:45Z [08_run_val_ablation_grid] checkpoint: eval graph=prime mode=trace steps=16
- 2026-05-05T00:46:46Z [disk] WORKDIR usage 70GB within 700GB budget
- 2026-05-05T01:20:00Z [08_run_val_ablation_grid] checkpoint: generation graph=prime mode=full steps=12
- 2026-05-05T01:20:00Z [08_run_val_ablation_grid] checkpoint: eval graph=prime mode=full steps=12
- 2026-05-05T01:20:01Z [disk] WORKDIR usage 70GB within 700GB budget
- 2026-05-05T01:52:36Z [08_run_val_ablation_grid] checkpoint: generation graph=prime mode=full steps=16
- 2026-05-05T01:52:37Z [08_run_val_ablation_grid] checkpoint: eval graph=prime mode=full steps=16
- 2026-05-05T01:52:37Z [disk] WORKDIR usage 70GB within 700GB budget
- 2026-05-05T02:38:42Z [08_run_val_ablation_grid] checkpoint: generation graph=mag mode=off steps=12
- 2026-05-05T02:38:42Z [08_run_val_ablation_grid] checkpoint: eval graph=mag mode=off steps=12
- 2026-05-05T02:38:42Z [disk] WORKDIR usage 71GB within 700GB budget
- 2026-05-05T03:25:39Z [08_run_val_ablation_grid] checkpoint: generation graph=mag mode=off steps=16
- 2026-05-05T03:25:39Z [08_run_val_ablation_grid] checkpoint: eval graph=mag mode=off steps=16
- 2026-05-05T03:25:39Z [disk] WORKDIR usage 71GB within 700GB budget
- 2026-05-05T04:10:31Z [08_run_val_ablation_grid] checkpoint: generation graph=mag mode=profile steps=12
- 2026-05-05T04:10:31Z [08_run_val_ablation_grid] checkpoint: eval graph=mag mode=profile steps=12
- 2026-05-05T04:10:32Z [disk] WORKDIR usage 71GB within 700GB budget
- 2026-05-05T04:53:49Z [08_run_val_ablation_grid] checkpoint: generation graph=mag mode=profile steps=16
- 2026-05-05T04:53:49Z [08_run_val_ablation_grid] checkpoint: eval graph=mag mode=profile steps=16
- 2026-05-05T04:53:49Z [disk] WORKDIR usage 71GB within 700GB budget
- 2026-05-05T05:29:22Z [08_run_val_ablation_grid] checkpoint: generation graph=mag mode=trace steps=12
- 2026-05-05T05:29:22Z [08_run_val_ablation_grid] checkpoint: eval graph=mag mode=trace steps=12
- 2026-05-05T05:29:23Z [disk] WORKDIR usage 71GB within 700GB budget
- 2026-05-05T06:06:22Z [08_run_val_ablation_grid] checkpoint: generation graph=mag mode=trace steps=16
- 2026-05-05T06:06:22Z [08_run_val_ablation_grid] checkpoint: eval graph=mag mode=trace steps=16
- 2026-05-05T06:06:22Z [disk] WORKDIR usage 71GB within 700GB budget
- 2026-05-05T06:43:39Z [08_run_val_ablation_grid] checkpoint: generation graph=mag mode=full steps=12
- 2026-05-05T06:43:39Z [08_run_val_ablation_grid] checkpoint: eval graph=mag mode=full steps=12
- 2026-05-05T06:43:40Z [disk] WORKDIR usage 71GB within 700GB budget
- 2026-05-05T07:21:09Z [08_run_val_ablation_grid] checkpoint: generation graph=mag mode=full steps=16
- 2026-05-05T07:21:10Z [08_run_val_ablation_grid] checkpoint: eval graph=mag mode=full steps=16
- 2026-05-05T07:21:16Z [disk] WORKDIR usage 71GB within 700GB budget
- 2026-05-05T08:16:35Z [08_run_val_ablation_grid] checkpoint: generation graph=amazon mode=off steps=12
- 2026-05-05T08:16:36Z [08_run_val_ablation_grid] checkpoint: eval graph=amazon mode=off steps=12
- 2026-05-05T08:16:36Z [disk] WORKDIR usage 73GB within 700GB budget
- 2026-05-05T09:12:06Z [08_run_val_ablation_grid] checkpoint: generation graph=amazon mode=off steps=16
- 2026-05-05T09:12:06Z [08_run_val_ablation_grid] checkpoint: eval graph=amazon mode=off steps=16
- 2026-05-05T09:12:07Z [disk] WORKDIR usage 73GB within 700GB budget
- 2026-05-05T10:07:58Z [08_run_val_ablation_grid] checkpoint: generation graph=amazon mode=profile steps=12
- 2026-05-05T10:07:58Z [08_run_val_ablation_grid] checkpoint: eval graph=amazon mode=profile steps=12
- 2026-05-05T10:07:58Z [disk] WORKDIR usage 73GB within 700GB budget
- 2026-05-05T13:28:59Z [08_run_val_ablation_grid] SUCCEEDED: validation grid complete with 24/24 metrics files
- 2026-05-05T15:37:24Z [06_stop_vllm] SUCCEEDED: stopped idle Qwen3-14B vLLM after Stage A; GPUs 1-3 free
- 2026-05-05T15:37:28Z [11_collect_tables] SUCCEEDED: Stage B table collection wrote /home/ubuntu/par_ark_workspace/ark/paper_tables/par_ark_tables.md
- 2026-05-05T15:38:04Z [Stage B analysis] checkpoint: validation favors off baseline by average MRR; Stage C should keep off vs full at max_steps=16 and record PAR-ARK full-test evidence
- 2026-05-05T15:38:04Z [Stage B plan] checkpoint: B1 is analysis/table selection; B2 is 30B-A3B pilot calibration before the multi-day full Stage C run
- 2026-05-05T15:41:24Z [09_serve_qwen3_30b_a3b_tp2] RUNNING: launched Qwen3-30B-A3B on GPUs 1,2 with no CPU offload
- 2026-05-05T15:50:49Z [09_serve_qwen3_30b_a3b_tp2] checkpoint: server healthy on http://localhost:8000/v1/models after model download/load/compile
- 2026-05-05T15:52:56Z [17_run_stage_b2_30b_pilot] RUNNING: started B2 pilot, test split, limit=50, modes=off/full, graphs=prime/mag/amazon
- 2026-05-05T15:57:43Z [17_run_stage_b2_30b_pilot] checkpoint: pilot alive on prime/off at 26/50 completed, 1 isolated context-window error, GPUs 1,2 active
- 2026-05-05T17:17:45Z [17_run_stage_b2_30b_pilot] SUCCEEDED: B2 pilot complete with 6/6 metrics files
- 2026-05-05T22:18:27Z [06_stop_vllm] SUCCEEDED: stopped idle Qwen3-30B-A3B server; no PAR-ARK vLLM process remains; GPUs 1,2,3 free

## Results Summary Through Stage B2

Full result details are mirrored in `RESULTS.md`. This runbook section intentionally records the key numeric tables and takeaways in-place as well.

### Stage A Result Table

Stage A used `Qwen/Qwen3-14B`, split `val`, `limit=100`, graphs `prime/mag/amazon`, modes `off/profile/trace/full`, and step budgets `12/16`. It completed 24/24 cells.

| Graph | Mode | Steps | n | Hit@1 | Hit@5 | R@20 | MRR | TimeMean(s) | StepsMean |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| prime | off | 12 | 100 | 0.2100 | 0.3500 | 0.3489 | 0.2736 | 20.684 | 3.920 |
| prime | off | 16 | 100 | 0.1600 | 0.3200 | 0.3112 | 0.2326 | 20.887 | 3.940 |
| prime | profile | 12 | 100 | 0.1700 | 0.3100 | 0.3358 | 0.2295 | 23.721 | 5.210 |
| prime | profile | 16 | 100 | 0.1300 | 0.3600 | 0.3545 | 0.2350 | 23.321 | 5.250 |
| prime | trace | 12 | 100 | 0.1400 | 0.2200 | 0.1982 | 0.1785 | 19.031 | 5.740 |
| prime | trace | 16 | 100 | 0.1500 | 0.2600 | 0.2262 | 0.1957 | 18.712 | 6.160 |
| prime | full | 12 | 100 | 0.1500 | 0.2300 | 0.2070 | 0.1885 | 19.864 | 6.390 |
| prime | full | 16 | 100 | 0.1300 | 0.2000 | 0.1945 | 0.1619 | 19.479 | 5.770 |
| mag | off | 12 | 100 | 0.3700 | 0.5500 | 0.4964 | 0.4394 | 26.316 | 4.110 |
| mag | off | 16 | 100 | 0.3900 | 0.5700 | 0.5127 | 0.4683 | 28.070 | 4.130 |
| mag | profile | 12 | 100 | 0.2700 | 0.4400 | 0.4029 | 0.3360 | 26.827 | 4.620 |
| mag | profile | 16 | 100 | 0.2300 | 0.4400 | 0.3850 | 0.3140 | 25.880 | 4.660 |
| mag | trace | 12 | 100 | 0.2300 | 0.4200 | 0.3678 | 0.3069 | 21.233 | 5.360 |
| mag | trace | 16 | 100 | 0.2900 | 0.4800 | 0.4196 | 0.3611 | 22.099 | 5.410 |
| mag | full | 12 | 100 | 0.2500 | 0.4200 | 0.3639 | 0.3147 | 22.274 | 5.660 |
| mag | full | 16 | 100 | 0.2500 | 0.4400 | 0.3835 | 0.3234 | 22.404 | 5.710 |
| amazon | off | 12 | 100 | 0.4200 | 0.6300 | 0.4303 | 0.5130 | 30.823 | 3.070 |
| amazon | off | 16 | 100 | 0.4200 | 0.6300 | 0.4338 | 0.5165 | 33.189 | 3.050 |
| amazon | profile | 12 | 100 | 0.4100 | 0.6100 | 0.4147 | 0.4878 | 33.397 | 3.330 |
| amazon | profile | 16 | 100 | 0.4000 | 0.6100 | 0.4149 | 0.4930 | 31.140 | 3.340 |
| amazon | trace | 12 | 100 | 0.3300 | 0.4900 | 0.2859 | 0.3979 | 22.983 | 5.260 |
| amazon | trace | 16 | 100 | 0.3800 | 0.5100 | 0.3128 | 0.4352 | 19.172 | 5.190 |
| amazon | full | 12 | 99 | 0.3737 | 0.5354 | 0.3398 | 0.4392 | 21.725 | 5.242 |
| amazon | full | 16 | 100 | 0.3900 | 0.5300 | 0.3214 | 0.4456 | 24.313 | 5.080 |

Stage A averages across graphs:

| Mode | Steps | Avg Hit@1 | Avg Hit@5 | Avg R@20 | Avg MRR | Avg Time(s) |
|---|---:|---:|---:|---:|---:|---:|
| off | 12 | 0.3333 | 0.5100 | 0.4252 | 0.4087 | 25.941 |
| off | 16 | 0.3233 | 0.5067 | 0.4192 | 0.4058 | 27.382 |
| profile | 12 | 0.2833 | 0.4533 | 0.3845 | 0.3511 | 27.982 |
| profile | 16 | 0.2533 | 0.4700 | 0.3848 | 0.3473 | 26.780 |
| trace | 12 | 0.2333 | 0.3767 | 0.2840 | 0.2944 | 21.082 |
| trace | 16 | 0.2733 | 0.4167 | 0.3195 | 0.3307 | 19.994 |
| full | 12 | 0.2579 | 0.3951 | 0.3036 | 0.3141 | 21.288 |
| full | 16 | 0.2567 | 0.3900 | 0.2998 | 0.3103 | 22.065 |

Stage A takeaway: `off` was the strongest average configuration by MRR, Hit@5, and R@20. `full` produced useful action telemetry but underperformed `off` under the Qwen3-14B validation setup. One caveat: `amazon/full/steps=12` had `n=99`.

### Stage B1 Result

B1 collected paper tables to `/home/ubuntu/par_ark_workspace/ark/paper_tables/par_ark_tables.md` and recorded the selection summary in `STAGE_B_SUMMARY.md`. The B1 decision was to keep `off` as the control and `full` as the complete PAR-ARK candidate for final evidence, with `max_steps=16`.

### Stage B2 Result Table

B2 used `Qwen/Qwen3-30B-A3B-Instruct-2507`, split `test`, `limit=50`, graphs `prime/mag/amazon`, modes `off/full`, `max_steps=16`, and TP2 on GPUs 1,2. It completed 6/6 cells.

| Graph | Mode | n | Hit@1 | Hit@5 | R@20 | MRR | TimeMean(s) | StepsMean |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| prime | off | 49 | 0.3061 | 0.4082 | 0.3952 | 0.3502 | 9.435 | 5.714 |
| prime | full | 50 | 0.2200 | 0.3200 | 0.3051 | 0.2670 | 7.444 | 8.920 |
| mag | off | 49 | 0.7551 | 0.8776 | 0.7464 | 0.8105 | 12.483 | 4.551 |
| mag | full | 50 | 0.4400 | 0.5400 | 0.4608 | 0.4797 | 6.951 | 6.140 |
| amazon | off | 50 | 0.5800 | 0.7800 | 0.4592 | 0.6600 | 10.251 | 4.120 |
| amazon | full | 50 | 0.4400 | 0.6400 | 0.3798 | 0.5150 | 6.333 | 6.520 |

B2 full-minus-off deltas:

| Graph | Delta Hit@1 | Delta Hit@5 | Delta R@20 | Delta MRR | Delta Time(s) |
|---|---:|---:|---:|---:|---:|
| prime | -0.0861 | -0.0882 | -0.0901 | -0.0832 | -1.991 |
| mag | -0.3151 | -0.3376 | -0.2856 | -0.3308 | -5.532 |
| amazon | -0.1400 | -0.1400 | -0.0794 | -0.1450 | -3.918 |

B2 takeaway: the 30B pilot repeated the Stage A pattern. `off` beat `full` on every graph by MRR, Hit@5, and R@20. `full` ran faster per question in this pilot and generated action telemetry, but accuracy was worse. The evidence so far does not justify expecting `full` to beat `off` in a multi-day Stage C run unless the method is changed or Stage C is explicitly framed as diagnostic/negative-result evidence.
- 2026-05-05T11:00:03Z [08_run_val_ablation_grid] checkpoint: generation graph=amazon mode=profile steps=16
- 2026-05-05T11:00:04Z [08_run_val_ablation_grid] checkpoint: eval graph=amazon mode=profile steps=16
- 2026-05-05T11:00:04Z [disk] WORKDIR usage 73GB within 700GB budget
- 2026-05-05T11:38:33Z [08_run_val_ablation_grid] checkpoint: generation graph=amazon mode=trace steps=12
- 2026-05-05T11:38:34Z [08_run_val_ablation_grid] checkpoint: eval graph=amazon mode=trace steps=12
- 2026-05-05T11:38:34Z [disk] WORKDIR usage 73GB within 700GB budget
- 2026-05-05T12:10:42Z [08_run_val_ablation_grid] checkpoint: generation graph=amazon mode=trace steps=16
- 2026-05-05T12:10:43Z [08_run_val_ablation_grid] checkpoint: eval graph=amazon mode=trace steps=16
- 2026-05-05T12:10:43Z [disk] WORKDIR usage 73GB within 700GB budget
- 2026-05-05T12:48:15Z [08_run_val_ablation_grid] checkpoint: generation graph=amazon mode=full steps=12
- 2026-05-05T12:48:16Z [08_run_val_ablation_grid] checkpoint: eval graph=amazon mode=full steps=12
- 2026-05-05T12:48:16Z [disk] WORKDIR usage 73GB within 700GB budget
- 2026-05-05T13:28:58Z [08_run_val_ablation_grid] checkpoint: generation graph=amazon mode=full steps=16
- 2026-05-05T13:28:59Z [08_run_val_ablation_grid] checkpoint: eval graph=amazon mode=full steps=16
- 2026-05-05T13:28:59Z [disk] WORKDIR usage 73GB within 700GB budget
- 2026-05-05T13:28:59Z [08_run_val_ablation_grid] SUCCEEDED: validation grid complete
- 2026-05-05T13:28:59Z [08_run_val_ablation_grid] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/08_run_val_ablation_grid.log
- 2026-05-05T13:28:59Z [08_run_val_ablation_grid] checkpoint: completed successfully
- 2026-05-05T15:37:18Z [06_stop_vllm] RUNNING: stopping vLLM processes
- 2026-05-05T15:37:21Z [07_serve_qwen3_14b_1gpu] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/07_serve_qwen3_14b_1gpu.log
- 2026-05-05T15:37:21Z [07_serve_qwen3_14b_1gpu] checkpoint: completed successfully
- 2026-05-05T15:37:24Z [06_stop_vllm] checkpoint: vLLM stop attempted
- 2026-05-05T15:37:24Z [06_stop_vllm] SUCCEEDED: vLLM stop attempted
- 2026-05-05T15:37:28Z [11_collect_tables] RUNNING: collecting paper tables
- 2026-05-05T15:37:28Z [11_collect_tables] checkpoint: tables written
- 2026-05-05T15:37:28Z [11_collect_tables] SUCCEEDED: tables attempted at /home/ubuntu/par_ark_workspace/ark/paper_tables/par_ark_tables.md
- 2026-05-05T15:41:24Z [09_serve_qwen3_30b_a3b_tp2] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/09_serve_qwen3_30b_a3b_tp2.detached.log
- 2026-05-05T15:41:24Z [09_serve_qwen3_30b_a3b_tp2] DETACHED: pid=2911830 log=/home/ubuntu/par_ark_workspace/run_state/logs/09_serve_qwen3_30b_a3b_tp2.detached.log
- 2026-05-05T15:41:24Z [09_serve_qwen3_30b_a3b_tp2] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/09_serve_qwen3_30b_a3b_tp2.log
- 2026-05-05T15:41:24Z [09_serve_qwen3_30b_a3b_tp2] RUNNING: starting vLLM Qwen3-30B-A3B on GPUs 1,2
- 2026-05-05T15:41:25Z [disk] WORKDIR usage 73GB within 700GB budget
- 2026-05-05T15:41:25Z [09_serve_qwen3_30b_a3b_tp2] checkpoint: launching TP2 vLLM on CUDA_VISIBLE_DEVICES=1,2
- 2026-05-05T15:52:56Z [17_run_stage_b2_30b_pilot] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/17_run_stage_b2_30b_pilot.detached.log
- 2026-05-05T15:52:56Z [17_run_stage_b2_30b_pilot] DETACHED: pid=2913063 log=/home/ubuntu/par_ark_workspace/run_state/logs/17_run_stage_b2_30b_pilot.detached.log
- 2026-05-05T15:52:56Z [17_run_stage_b2_30b_pilot] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/17_run_stage_b2_30b_pilot.log
- 2026-05-05T15:52:56Z [17_run_stage_b2_30b_pilot] RUNNING: Qwen3-30B-A3B pilot calibration
- 2026-05-05T16:01:04Z [17_run_stage_b2_30b_pilot] checkpoint: generation graph=prime mode=off limit=50
- 2026-05-05T16:01:04Z [17_run_stage_b2_30b_pilot] checkpoint: eval graph=prime mode=off limit=50
- 2026-05-05T16:01:05Z [disk] WORKDIR usage 130GB within 700GB budget
- 2026-05-05T16:07:25Z [17_run_stage_b2_30b_pilot] checkpoint: generation graph=prime mode=full limit=50
- 2026-05-05T16:07:25Z [17_run_stage_b2_30b_pilot] checkpoint: eval graph=prime mode=full limit=50
- 2026-05-05T16:07:25Z [disk] WORKDIR usage 130GB within 700GB budget
- 2026-05-05T16:57:35Z [17_run_stage_b2_30b_pilot] checkpoint: generation graph=mag mode=off limit=50
- 2026-05-05T16:57:35Z [17_run_stage_b2_30b_pilot] checkpoint: eval graph=mag mode=off limit=50
- 2026-05-05T16:57:35Z [disk] WORKDIR usage 130GB within 700GB budget
- 2026-05-05T17:03:32Z [17_run_stage_b2_30b_pilot] checkpoint: generation graph=mag mode=full limit=50
- 2026-05-05T17:03:32Z [17_run_stage_b2_30b_pilot] checkpoint: eval graph=mag mode=full limit=50
- 2026-05-05T17:03:32Z [disk] WORKDIR usage 130GB within 700GB budget
- 2026-05-05T17:12:16Z [17_run_stage_b2_30b_pilot] checkpoint: generation graph=amazon mode=off limit=50
- 2026-05-05T17:12:16Z [17_run_stage_b2_30b_pilot] checkpoint: eval graph=amazon mode=off limit=50
- 2026-05-05T17:12:16Z [disk] WORKDIR usage 130GB within 700GB budget
- 2026-05-05T17:17:44Z [17_run_stage_b2_30b_pilot] checkpoint: generation graph=amazon mode=full limit=50
- 2026-05-05T17:17:44Z [17_run_stage_b2_30b_pilot] checkpoint: eval graph=amazon mode=full limit=50
- 2026-05-05T17:17:45Z [disk] WORKDIR usage 130GB within 700GB budget
- 2026-05-05T17:17:45Z [17_run_stage_b2_30b_pilot] SUCCEEDED: 30B-A3B pilot complete
- 2026-05-05T17:17:45Z [17_run_stage_b2_30b_pilot] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/17_run_stage_b2_30b_pilot.log
- 2026-05-05T17:17:45Z [17_run_stage_b2_30b_pilot] checkpoint: completed successfully
- 2026-05-05T22:18:21Z [06_stop_vllm] RUNNING: stopping vLLM processes
- 2026-05-05T22:18:27Z [09_serve_qwen3_30b_a3b_tp2] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/09_serve_qwen3_30b_a3b_tp2.log
- 2026-05-05T22:18:27Z [09_serve_qwen3_30b_a3b_tp2] checkpoint: completed successfully
- 2026-05-05T22:18:27Z [06_stop_vllm] checkpoint: vLLM stop attempted
- 2026-05-05T22:18:27Z [06_stop_vllm] SUCCEEDED: vLLM stop attempted
- 2026-05-05T22:48:20Z [09_serve_qwen3_30b_a3b_tp2] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/09_serve_qwen3_30b_a3b_tp2.detached.log
- 2026-05-05T22:48:20Z [09_serve_qwen3_30b_a3b_tp2] DETACHED: pid=2926006 log=/home/ubuntu/par_ark_workspace/run_state/logs/09_serve_qwen3_30b_a3b_tp2.detached.log
- 2026-05-05T22:48:20Z [09_serve_qwen3_30b_a3b_tp2] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/09_serve_qwen3_30b_a3b_tp2.log
- 2026-05-05T22:48:20Z [09_serve_qwen3_30b_a3b_tp2] RUNNING: starting vLLM Qwen3-30B-A3B on GPUs 1,2
- 2026-05-05T22:48:20Z [disk] WORKDIR usage 130GB within 700GB budget
- 2026-05-05T22:48:20Z [09_serve_qwen3_30b_a3b_tp2] checkpoint: launching TP2 vLLM on CUDA_VISIBLE_DEVICES=1,2
- 2026-05-05T22:50:16Z [18_run_stage_e_30b_subset] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/18_run_stage_e_30b_subset.detached.log
- 2026-05-05T22:50:16Z [18_run_stage_e_30b_subset] DETACHED: pid=2926742 log=/home/ubuntu/par_ark_workspace/run_state/logs/18_run_stage_e_30b_subset.detached.log
- 2026-05-05T22:50:16Z [18_run_stage_e_30b_subset] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/18_run_stage_e_30b_subset.log
- 2026-05-05T22:51:45Z [09_serve_qwen3_30b_a3b_tp2] HEALTHY: /v1/models returned Qwen/Qwen3-30B-A3B-Instruct-2507 with max_model_len=32768; GPUs 1,2 each using about 41673 MiB.
- 2026-05-05T22:51:45Z [18_run_stage_e_30b_subset] STABILITY CHECK: Stage E active in graph=prime mode=off; latest_progress.json reports completed=8/300, errors=0, current_question_id=6641.
- 2026-05-05T22:55:00Z [18_run_stage_e_30b_subset] STABILITY CHECK: after roughly 4.5 minutes, graph=prime mode=off reports completed=25/300, errors=0, latest_progress updated_at=2026-05-05T22:54:54Z. GPUs 1,2 are both active at 100% util and about 41729 MiB used. No crash/kill/OOM signal observed during the stability window; tqdm is live in /home/ubuntu/par_ark_workspace/run_state/logs/18_run_stage_e_30b_subset.log.
- 2026-05-05T23:03:36Z [4gpu_tp2] USER AUTHORIZED: kill three idle GPU0 PedagogicalRLTutor Python workers and prepare two TP2 replica execution.
- 2026-05-05T23:03:47Z [4gpu_tp2] ACTION: sent SIGTERM to GPU0 worker pids 2609872,2610741,2611714; post-kill GPU compute app snapshot recorded in shell output.
- 2026-05-05T23:03:55Z [20_serve_qwen3_30b_a3b_tp2_replica_b] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/20_serve_qwen3_30b_a3b_tp2_replica_b.detached.log
- 2026-05-05T23:03:55Z [20_serve_qwen3_30b_a3b_tp2_replica_b] DETACHED: pid=2928258 log=/home/ubuntu/par_ark_workspace/run_state/logs/20_serve_qwen3_30b_a3b_tp2_replica_b.detached.log
- 2026-05-05T23:03:55Z [20_serve_qwen3_30b_a3b_tp2_replica_b] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/20_serve_qwen3_30b_a3b_tp2_replica_b.log
- 2026-05-05T23:03:55Z [20_serve_qwen3_30b_a3b_tp2_replica_b] RUNNING: starting TP2 vLLM replica on GPUs 0,3 port 8001
- 2026-05-05T23:03:56Z [disk] WORKDIR usage 130GB within 700GB budget
- 2026-05-05T23:03:56Z [20_serve_qwen3_30b_a3b_tp2_replica_b] checkpoint: launching TP2 vLLM replica model=Qwen/Qwen3-30B-A3B-Instruct-2507 CUDA_VISIBLE_DEVICES=0,3 port=8001 max_model_len=32768 gpu_memory_utilization=0.90
- 2026-05-05T23:04:03Z [20_serve_qwen3_30b_a3b_tp2_replica_b] FAILED: rc=1 log=/home/ubuntu/par_ark_workspace/run_state/logs/20_serve_qwen3_30b_a3b_tp2_replica_b.log
- 2026-05-05T23:06:29Z [20_serve_qwen3_30b_a3b_tp2_replica_b] FAILED: first attempt on GPUs 0,3 port 8001 exited before model load with OSError address already in use; GPUs 0,3 remained free. Will retry on a clean port.
- 2026-05-05T23:06:47Z [20_serve_qwen3_30b_a3b_tp2_replica_b_8100] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/20_serve_qwen3_30b_a3b_tp2_replica_b_8100.detached.log
- 2026-05-05T23:06:47Z [20_serve_qwen3_30b_a3b_tp2_replica_b_8100] DETACHED: pid=2928599 log=/home/ubuntu/par_ark_workspace/run_state/logs/20_serve_qwen3_30b_a3b_tp2_replica_b_8100.detached.log
- 2026-05-05T23:06:47Z [20_serve_qwen3_30b_a3b_tp2_replica_b_8100] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/20_serve_qwen3_30b_a3b_tp2_replica_b_8100.log
- 2026-05-05T23:06:47Z [20_serve_qwen3_30b_a3b_tp2_replica_b_8100] RUNNING: starting TP2 vLLM replica on GPUs 0,3 port 8100
- 2026-05-05T23:06:47Z [disk] WORKDIR usage 130GB within 700GB budget
- 2026-05-05T23:06:47Z [20_serve_qwen3_30b_a3b_tp2_replica_b_8100] checkpoint: launching TP2 vLLM replica model=Qwen/Qwen3-30B-A3B-Instruct-2507 CUDA_VISIBLE_DEVICES=0,3 port=8100 max_model_len=32768 gpu_memory_utilization=0.90
- 2026-05-05T23:07:41Z [20_serve_qwen3_30b_a3b_tp2_replica_b_8100] HEALTHY: second TP2 replica running on GPUs 0,3 at http://localhost:8100/v1/models with max_model_len=32768.
- 2026-05-05T23:07:53Z [18_run_stage_e_30b_subset] ACTION: stopping serial Stage E client before launching two-replica shards; completed prime/off logs will be reused via par_main skip-existing resume.
- 2026-05-05T23:07:58Z [18_run_stage_e_30b_subset] STOPPED: serial client stopped for two-TP2 shard relaunch.
- 2026-05-05T23:08:05Z [18_run_stage_e_30b_subset] CLEANUP: stopped stale tail watcher for old serial Stage E log.
- 2026-05-05T23:08:20Z [18_run_stage_e_30b_subset_shard_a_8000] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/18_run_stage_e_30b_subset_shard_a_8000.detached.log
- 2026-05-05T23:08:20Z [18_run_stage_e_30b_subset_shard_a_8000] DETACHED: pid=2929224 log=/home/ubuntu/par_ark_workspace/run_state/logs/18_run_stage_e_30b_subset_shard_a_8000.detached.log
- 2026-05-05T23:08:20Z [18_run_stage_e_30b_subset_shard_a_8000] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/18_run_stage_e_30b_subset_shard_a_8000.log
- 2026-05-05T23:08:20Z [18_run_stage_e_30b_subset_shard_b_8100] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/18_run_stage_e_30b_subset_shard_b_8100.detached.log
- 2026-05-05T23:08:20Z [18_run_stage_e_30b_subset_shard_b_8100] DETACHED: pid=2929248 log=/home/ubuntu/par_ark_workspace/run_state/logs/18_run_stage_e_30b_subset_shard_b_8100.detached.log
- 2026-05-05T23:08:20Z [18_run_stage_e_30b_subset_shard_b_8100] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/18_run_stage_e_30b_subset_shard_b_8100.log
- 2026-05-05T23:09:26Z [18_run_stage_e_30b_subset_sharded] STABILITY CHECK: shard_a_8000 is resuming prime/off with completed=95/300 errors=0 in the relaunched process; shard_b_8100 is running mag/off with completed=4/300 errors=0. All four L40S GPUs active.
- 2026-05-05T23:14:14Z [25_run_deadline_e_f_g_supervisor] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/25_run_deadline_e_f_g_supervisor.detached.log
- 2026-05-05T23:14:14Z [25_run_deadline_e_f_g_supervisor] DETACHED: pid=2930489 log=/home/ubuntu/par_ark_workspace/run_state/logs/25_run_deadline_e_f_g_supervisor.detached.log
- 2026-05-05T23:14:14Z [25_run_deadline_e_f_g_supervisor] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/25_run_deadline_e_f_g_supervisor.log
- 2026-05-05T23:14:14Z [25_run_deadline_e_f_g_supervisor] RUNNING: watching Stage E, then launching Stage F shards and Stage G diagnostics
- 2026-05-05T23:14:14Z [25_run_deadline_e_f_g_supervisor] checkpoint: supervisor started; Stage E target metrics=6 Stage F target metrics=3
- 2026-05-05T23:14:14Z [25_run_deadline_e_f_g_supervisor] waiting for Stage E metrics: 0/6 complete
- 2026-05-05T23:15:33Z [18_run_stage_e_30b_subset_sharded] STABILITY CHECK: one-minute post-supervisor check shows shard_a prime/off completed=139/300 errors=2; shard_b mag/off completed=40/300 errors=0; both shard statuses RUNNING; supervisor RUNNING; all four GPUs at 100% util.
- 2026-05-05T23:44:14Z [25_run_deadline_e_f_g_supervisor] waiting for Stage E metrics: 0/6 complete
- 2026-05-06T00:09:41Z [18_run_stage_e_30b_subset_shard_b_8100] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/18_run_stage_e_30b_subset_shard_b_8100.log
- 2026-05-06T00:09:41Z [18_run_stage_e_30b_subset_shard_b_8100] checkpoint: completed successfully
- 2026-05-06T00:14:14Z [25_run_deadline_e_f_g_supervisor] waiting for Stage E metrics: 2/6 complete
- 2026-05-06T00:27:12Z [status_check] Stage E status: metrics=3/6 complete (prime/off, prime/full, mag/off). Active cell mag/full completed=39/300 errors=0 as of log tail; progress JSON slightly earlier showed 37/300. Shard B finished mag/off and second replica is idle; shard A/server A is running remaining cells. GPUs 1,2 active; GPUs 0,3 loaded but idle until supervisor launches Stage F unless workload is manually resharded.
- 2026-05-06T00:44:14Z [25_run_deadline_e_f_g_supervisor] waiting for Stage E metrics: 3/6 complete
- 2026-05-06T01:14:14Z [25_run_deadline_e_f_g_supervisor] waiting for Stage E metrics: 4/6 complete
- 2026-05-06T01:44:14Z [25_run_deadline_e_f_g_supervisor] waiting for Stage E metrics: 4/6 complete
- 2026-05-06T02:14:14Z [25_run_deadline_e_f_g_supervisor] waiting for Stage E metrics: 5/6 complete
- 2026-05-06T02:23:54Z [18_run_stage_e_30b_subset_shard_a_8000] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/18_run_stage_e_30b_subset_shard_a_8000.log
- 2026-05-06T02:23:54Z [18_run_stage_e_30b_subset_shard_a_8000] checkpoint: completed successfully
- 2026-05-06T02:24:14Z [25_run_deadline_e_f_g_supervisor] checkpoint: Stage E metrics complete: 6/6
- 2026-05-06T02:24:14Z [25_run_deadline_e_f_g_supervisor] checkpoint: launching Stage F two-replica budget-fix shards
- 2026-05-06T02:24:14Z [19_run_stage_f_budgetfix_probe_shard_a_8000] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/19_run_stage_f_budgetfix_probe_shard_a_8000.detached.log
- 2026-05-06T02:24:14Z [19_run_stage_f_budgetfix_probe_shard_a_8000] DETACHED: pid=2936149 log=/home/ubuntu/par_ark_workspace/run_state/logs/19_run_stage_f_budgetfix_probe_shard_a_8000.detached.log
- 2026-05-06T02:24:14Z [19_run_stage_f_budgetfix_probe_shard_a_8000] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/19_run_stage_f_budgetfix_probe_shard_a_8000.log
- 2026-05-06T02:24:14Z [19_run_stage_f_budgetfix_probe_shard_b_8100] LAUNCHING: detached log=/home/ubuntu/par_ark_workspace/run_state/logs/19_run_stage_f_budgetfix_probe_shard_b_8100.detached.log
- 2026-05-06T02:24:14Z [19_run_stage_f_budgetfix_probe_shard_b_8100] DETACHED: pid=2936170 log=/home/ubuntu/par_ark_workspace/run_state/logs/19_run_stage_f_budgetfix_probe_shard_b_8100.detached.log
- 2026-05-06T02:24:14Z [19_run_stage_f_budgetfix_probe_shard_b_8100] RUNNING: log=/home/ubuntu/par_ark_workspace/run_state/logs/19_run_stage_f_budgetfix_probe_shard_b_8100.log
- 2026-05-06T02:24:14Z [25_run_deadline_e_f_g_supervisor] waiting for Stage F metrics: 0/3 complete
- 2026-05-06T02:37:08Z [19_run_stage_f_budgetfix_probe_shard_b_8100] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/19_run_stage_f_budgetfix_probe_shard_b_8100.log
- 2026-05-06T02:37:08Z [19_run_stage_f_budgetfix_probe_shard_b_8100] checkpoint: completed successfully
- 2026-05-06T02:46:45Z [19_run_stage_f_budgetfix_probe_shard_a_8000] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/19_run_stage_f_budgetfix_probe_shard_a_8000.log
- 2026-05-06T02:46:45Z [19_run_stage_f_budgetfix_probe_shard_a_8000] checkpoint: completed successfully
- 2026-05-06T02:49:14Z [25_run_deadline_e_f_g_supervisor] checkpoint: Stage F metrics complete: 3/3
- 2026-05-06T02:49:14Z [25_run_deadline_e_f_g_supervisor] checkpoint: running Stage G paired diagnostics and regenerating tables
- 2026-05-06T02:49:15Z [25_run_deadline_e_f_g_supervisor] SUCCEEDED: Stage E/F/G supervisor complete; diagnostics and tables attempted
- 2026-05-06T02:49:15Z [25_run_deadline_e_f_g_supervisor] checkpoint: completed successfully
- 2026-05-06T02:49:15Z [25_run_deadline_e_f_g_supervisor] SUCCEEDED: log=/home/ubuntu/par_ark_workspace/run_state/logs/25_run_deadline_e_f_g_supervisor.log
- 2026-05-06T02:49:15Z [25_run_deadline_e_f_g_supervisor] checkpoint: completed successfully
- 2026-05-06T07:15:00Z [final_status] Stage E complete: 6/6 metrics. Completed cells: prime/off, prime/full, mag/off, mag/full, amazon/off, amazon/full.
- 2026-05-06T07:15:00Z [final_status] Stage F complete: 3/3 metrics. Completed cells: prime/full budgetfix, mag/full budgetfix, amazon/full budgetfix.
- 2026-05-06T07:15:00Z [final_status] Stage G complete: paired diagnostics and JSON summaries written for prime, mag, amazon; deadline_all_tables.md regenerated.
- 2026-05-06T07:15:00Z [final_status] Main caveats: Stage E off-cell context/error counts were prime 10/300, mag 1/300, amazon 4/300; all below 5% stop threshold. Full cells completed 300/300. First second-replica attempt on port 8001 failed with address-in-use; successful retry used port 8100. Serial Stage E client was intentionally stopped and relaunched as resumable shards.
- 2026-05-06T07:15:00Z [final_status] Evidence direction: results support a failure/diagnostic paper. Qwen3-30B Stage E full underperforms off on all graphs by MRR, Hit@5, and R@20; Stage F reduces trace budgets/runtime but does not restore accuracy.
- 2026-05-06T07:15:00Z [documentation] RESULTS.md updated through Stage G with Stage E/F/G metrics, paired diagnostics, operational caveats, failed attempts, and takeaways.
- 2026-05-06T08:53:00Z [results_bundle] Created exhaustive results folder at /home/ubuntu/nachiket/Ablations/PStuff/PAR-ARK/results/par_ark_deadline_results_2026_05_06_0715 with updated docs, paper tables, diagnostics, summaries, raw experiment traces, run_state logs/status/checkpoints, scripts, rescue package, server health snapshots, manifest, and checksums.
- 2026-05-06T08:53:00Z [results_bundle] Created zip archive /home/ubuntu/nachiket/Ablations/PStuff/PAR-ARK/results/par_ark_deadline_results_2026_05_06_0715.zip and verified it with unzip -tq; archive size is about 28 MB.
