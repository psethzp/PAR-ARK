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
