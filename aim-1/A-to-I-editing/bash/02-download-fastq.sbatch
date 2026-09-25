#!/bin/bash
#SBATCH --job-name=dl_GSE99249
#SBATCH --output=logs/dl_%A_%a.out
#SBATCH --error=logs/dl_%A_%a.err
#SBATCH --array=6-6
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --time=04:00:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

# Define output directory
OUTDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/raw-data/GSE99249"

# Create logs directory (full path)
mkdir -p logs

# Load conda environment
ml conda
conda activate /blue/cancercenter-dept/conda_envs/sra_tools

# Get the SRR ID for this array task (NOTE: fixed filename to srr_list.txt)
SRR=$(sed -n "${SLURM_ARRAY_TASK_ID}p" srr-list.txt)

echo "Downloading $SRR (job ${SLURM_ARRAY_TASK_ID} of 6)"
date

# Download directly to output directory
fastq-dump --split-files --gzip --outdir ${OUTDIR} $SRR

echo "Completed $SRR"
date
