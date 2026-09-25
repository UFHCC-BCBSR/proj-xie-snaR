#!/bin/bash
#SBATCH --job-name=compress_all
#SBATCH --output=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/02_compress_%j.log
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=8gb
#SBATCH --account=mingyi.xie
#SBATCH --qos=mingyi.xie-b

ml gcc/5.2.0 pigz/2.4

FASTQ_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/fastq"

echo "=========================================="
echo "Compressing all fastq files"
echo "Start time: $(date)"
echo "Directory: ${FASTQ_DIR}"
echo "=========================================="

cd ${FASTQ_DIR}

for FILE in *.fastq; do
    if [ -f "$FILE" ]; then
        echo "Compressing $FILE with pigz..."
        pigz -p 8 "$FILE"
    fi
done

echo "Completed all compressions"
echo "End time: $(date)"
