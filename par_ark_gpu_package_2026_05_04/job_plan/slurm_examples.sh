#!/usr/bin/env bash
# Example only. Adapt partition/account/time.

cat > serve_q30b.sbatch <<'SLURM'
#!/bin/bash
#SBATCH --job-name=vllm-q30b
#SBATCH --gres=gpu:2
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=24:00:00
cd $HOME/par_ark_workspace/ark
export CUDA_VISIBLE_DEVICES=0,1
export VLLM_PORT=8000
uv run vllm serve Qwen/Qwen3-30B-A3B-Instruct-2507 \
  --served-model-name Qwen/Qwen3-30B-A3B-Instruct-2507 \
  --host 0.0.0.0 --port 8000 \
  --dtype bfloat16 --tensor-parallel-size 2 \
  --max-model-len 32768 --max-num-seqs 1 --gpu-memory-utilization 0.90 \
  --enable-auto-tool-choice --tool-call-parser hermes
SLURM

cat > run_final.sbatch <<'SLURM'
#!/bin/bash
#SBATCH --job-name=parark-final
#SBATCH --gres=gpu:0
#SBATCH --cpus-per-task=16
#SBATCH --mem=128G
#SBATCH --time=48:00:00
cd $HOME/par_ark_workspace/ark
export VLLM_PORT=8000
bash /path/to/package/scripts/10_run_final_tests.sh
SLURM
