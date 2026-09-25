#!/bin/bash
#SBATCH --job-name=dl_GSE99249
#SBATCH --output=logs/dl_%A_%a.out
#SBATCH --error=logs/dl_%A_%a.err
#SBATCH --array=6-6
#SBATCH --cpus-per-task=8  # Increase for parallel download
#SBATCH --mem=16G          # More memory for faster processing
#SBATCH --time=02:00:00    # Should be faster
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

OUTDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/raw-data/GSE99249"
TMPDIR="/orange/mingyi.xie/hkates/tmp"  # Temp directory for faster I/O

mkdir -p logs ${TMPDIR}

ml conda
conda activate /blue/cancercenter-dept/conda_envs/sra_tools

SRR=$(sed -n "${SLURM_ARRAY_TASK_ID}p" srr-list.txt)

echo "Downloading $SRR with fasterq-dump (${SLURM_CPUS_PER_TASK} threads)"
date

# Use fasterq-dump (much faster, multi-threaded)
fasterq-dump ${SRR} \
    --outdir ${OUTDIR} \
    --temp ${TMPDIR} \
    --threads ${SLURM_CPUS_PER_TASK} \
    --split-files \
    --progress

# Compress the output (fasterq-dump doesn't gzip by default)
echo "Compressing..."
pigz -p ${SLURM_CPUS_PER_TASK} ${OUTDIR}/${SRR}_*.fastq

echo "Completed $SRR"
date
