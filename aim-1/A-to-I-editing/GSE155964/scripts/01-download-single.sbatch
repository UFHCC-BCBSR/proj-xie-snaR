#!/bin/bash
#SBATCH --job-name=download
#SBATCH --output=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/01_download_%x_%j.log
#SBATCH --time=04:00:00
#SBATCH --mem=8gb
#SBATCH --cpus-per-task=4
#SBATCH --account=mingyi.xie
#SBATCH --qos=mingyi.xie-b

ml sra

OUTDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/fastq"

echo "=========================================="
echo "Downloading ${SRR}"
echo "Start time: $(date)"
echo "Output: ${OUTDIR}"
echo "=========================================="

fasterq-dump --split-files \
  --outdir ${OUTDIR} \
  --threads 4 \
  ${SRR}

echo "Completed: ${SRR}"
echo "End time: $(date)"
