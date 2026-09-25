#!/bin/bash
#SBATCH --job-name=fastp_trim
#SBATCH --output=logs/trim_%A_%a.out
#SBATCH --error=logs/trim_%A_%a.err
#SBATCH --array=0-0
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=4:00:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

ml fastp

FASTQDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE271019/fastq"
TRIMDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE271019/fastq_trimmed"
QCDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE271019/fastp_reports"

mkdir -p ${TRIMDIR}
mkdir -p ${QCDIR}
mkdir -p logs

# Define variables
SRR="SRR29637065"

echo "Starting fastp trimming for ${SRR}"
date

# fastp for paired-end reads
fastp -i ${FASTQDIR}/${SRR}_1.fastq.gz \
      -I ${FASTQDIR}/${SRR}_2.fastq.gz \
      -o ${TRIMDIR}/${SRR}_1.trimmed.fastq.gz \
      -O ${TRIMDIR}/${SRR}_2.trimmed.fastq.gz \
      --detect_adapter_for_pe \
      --thread 8 \
      --length_required 20 \
      --html ${QCDIR}/${SRR}_fastp.html \
      --json ${QCDIR}/${SRR}_fastp.json

echo "Completed trimming for $SRR"
date
