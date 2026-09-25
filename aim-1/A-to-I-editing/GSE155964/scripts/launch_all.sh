#!/bin/bash
# launch_all.sh - Submit pipeline for each sample independently

SCRIPT_DIR="/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/scripts"
LOG_DIR="/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs"
SRR_LIST="$1"

if [ -z "$SRR_LIST" ]; then
    echo "Usage: $0 <SRR_list.txt>"
    exit 1
fi

if [ ! -f "$SRR_LIST" ]; then
    echo "Error: File '$SRR_LIST' not found"
    exit 1
fi

echo "=========================================="
echo "Launching pipeline for all samples"
echo "Working directory: /blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964"
echo "Output directory: /orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964"
echo "=========================================="
echo ""

JOBFILE="${LOG_DIR}/submitted_jobs_$(date +%Y%m%d_%H%M%S).txt"
echo "Sample,Download,Compress,Trim,Align,Coverage" > "$JOBFILE"

while read SRR; do
    # Skip empty lines and comments
    [[ -z "$SRR" || "$SRR" =~ ^# ]] && continue
    
    echo "Submitting pipeline for: ${SRR}"
    
    JOB1=$(sbatch --parsable --export=SRR=${SRR} --job-name=${SRR}_dl ${SCRIPT_DIR}/01-download-single.sbatch)
    JOB2=$(sbatch --parsable --dependency=afterok:${JOB1} --export=SRR=${SRR} --job-name=${SRR}_cmp ${SCRIPT_DIR}/02-compress-single.sbatch)
    JOB3=$(sbatch --parsable --dependency=afterok:${JOB2} --export=SRR=${SRR} --job-name=${SRR}_trm ${SCRIPT_DIR}/03-fastp-single.sbatch)
    JOB4=$(sbatch --parsable --dependency=afterok:${JOB3} --export=SRR=${SRR} --job-name=${SRR}_aln ${SCRIPT_DIR}/04-align-single.sbatch)
    JOB5=$(sbatch --parsable --dependency=afterok:${JOB4} --export=SRR=${SRR} --job-name=${SRR}_cvg ${SCRIPT_DIR}/05-coverage-single.sbatch)
    
    echo "  Jobs: ${JOB1} -> ${JOB2} -> ${JOB3} -> ${JOB4} -> ${JOB5}"
    echo "${SRR},${JOB1},${JOB2},${JOB3},${JOB4},${JOB5}" >> "$JOBFILE"
    
done < "$SRR_LIST"

echo ""
echo "=========================================="
echo "All pipelines submitted!"
echo "Job tracking file: $JOBFILE"
echo ""
echo "Monitor with: squeue -u $USER"
echo "Or: watch -n 10 'squeue -u $USER'"
echo "=========================================="
