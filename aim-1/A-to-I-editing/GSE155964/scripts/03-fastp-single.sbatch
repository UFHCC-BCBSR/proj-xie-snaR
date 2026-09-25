#!/bin/bash
#SBATCH --job-name=fastp
#SBATCH --output=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/03_fastp_%x_%j.log
#SBATCH --error=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/03_fastp_%x_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=4:00:00
#SBATCH --account=mingyi.xie
#SBATCH --qos=mingyi.xie-b

ml fastp

FASTQ_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/fastq"
TRIM_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/fastq_trimmed"
QC_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/fastp_reports"

echo "=========================================="
echo "Trimming ${SRR}"
echo "Start time: $(date)"
echo "=========================================="

fastp -i ${FASTQ_DIR}/${SRR}_1.fastq.gz \
      -I ${FASTQ_DIR}/${SRR}_2.fastq.gz \
      -o ${TRIM_DIR}/${SRR}_1.trimmed.fastq.gz \
      -O ${TRIM_DIR}/${SRR}_2.trimmed.fastq.gz \
      --detect_adapter_for_pe \
      --thread 8 \
      --length_required 20 \
      --html ${QC_DIR}/${SRR}_fastp.html \
      --json ${QC_DIR}/${SRR}_fastp.json

echo "Completed: ${SRR}"
echo "End time: $(date)"
