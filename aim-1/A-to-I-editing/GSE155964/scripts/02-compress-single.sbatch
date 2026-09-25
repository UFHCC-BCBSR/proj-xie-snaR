#!/bin/bash
#SBATCH --job-name=compress
#SBATCH --output=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/02_compress_%x_%j.log
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=8gb
#SBATCH --account=mingyi.xie
#SBATCH --qos=mingyi.xie-b

ml gcc/5.2.0
pigz/2.4

FASTQ_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/fastq"

echo "=========================================="
echo "Compressing ${SRR}"
echo "Start time: $(date)"
echo "Directory: ${FASTQ_DIR}"
echo "=========================================="

cd ${FASTQ_DIR}

for FILE in ${SRR}*.fastq; do
    if [ -f "$FILE" ]; then
        echo "Compressing $FILE with pigz..."
        pigz -p 8 "$FILE"
    fi
done

echo "Completed: ${SRR}"
echo "End time: $(date)"
