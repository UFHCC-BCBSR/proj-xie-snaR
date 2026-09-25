#!/bin/bash
#SBATCH --job-name=compress_fastq
#SBATCH --output=logs/compress_%A_%a.log
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=1
#SBATCH --array=1-4 #number of fastq files

cd /orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE271019/fastq

# Get list of fastq files into an array
FILES=(*.fastq)

# Get the file for this array task (arrays are 0-indexed, SLURM starts at 1)
FILE=${FILES[$SLURM_ARRAY_TASK_ID-1]}

# Compress the file
gzip "$FILE"
