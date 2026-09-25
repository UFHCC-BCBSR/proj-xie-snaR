#!/bin/bash
#SBATCH --job-name=download_sra
#SBATCH --output=logs/download_%j.log
#SBATCH --time=04:00:00
#SBATCH --mem=8gb
#SBATCH --cpus-per-task=4
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

ml sra

# Set output directory
OUTDIR=/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE56152/fastq

# Download to specific directory
fasterq-dump --split-files \
  --outdir $OUTDIR \
  --threads 4 \
  SRR1203776 SRR1203782 SRR1203788 SRR1203794

