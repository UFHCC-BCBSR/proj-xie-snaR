#!/bin/bash
#SBATCH --job-name=fastp
#SBATCH --output=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/03_fastp_%A_%a.log
#SBATCH --error=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/03_fastp_%A_%a.err
#SBATCH --array=0-3
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=4:00:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

ml fastp

FASTQ_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/fastq"
TRIM_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/fastq_trimmed"
QC_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/fastp_reports"

# Get list of all _1.fastq.gz files and extract sample names
cd ${FASTQ_DIR}
SAMPLES=($(ls *_1.fastq.gz | sed 's/_1.fastq.gz//'))

# Get the sample for this array task
SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

echo "=========================================="
echo "Processing sample: ${SAMPLE}"
echo "Array task ID: ${SLURM_ARRAY_TASK_ID}"
echo "Start time: $(date)"
echo "=========================================="

fastp -i ${FASTQ_DIR}/${SAMPLE}_1.fastq.gz \
      -I ${FASTQ_DIR}/${SAMPLE}_2.fastq.gz \
      -o ${TRIM_DIR}/${SAMPLE}_1.trimmed.fastq.gz \
      -O ${TRIM_DIR}/${SAMPLE}_2.trimmed.fastq.gz \
      --detect_adapter_for_pe \
      --thread 8 \
      --length_required 20 \
      --html ${QC_DIR}/${SAMPLE}_fastp.html \
      --json ${QC_DIR}/${SAMPLE}_fastp.json

echo "Completed: ${SAMPLE}"
echo "End time: $(date)"
