#!/bin/bash
# check_status.sh - Check pipeline status for all samples

OUTPUT_BASE="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964"
WORK_BASE="/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964"

echo "=========================================="
echo "Pipeline Status Check"
echo "=========================================="
echo ""

if [ ! -f "${WORK_BASE}/SRR-ids.txt" ]; then
    echo "Error: SRR-ids.txt not found"
    exit 1
fi

printf "%-15s %-10s %-10s %-10s %-10s %-10s\n" "Sample" "Download" "Compress" "Trim" "Align" "Coverage"
echo "--------------------------------------------------------------------------------"

while read SRR; do
    [[ -z "$SRR" || "$SRR" =~ ^# ]] && continue
    
    # Check for output files
    DL=$([ -f "${OUTPUT_BASE}/fastq/${SRR}_1.fastq.gz" ] && echo "✓" || echo "✗")
    TR=$([ -f "${OUTPUT_BASE}/fastq_trimmed/${SRR}_1.trimmed.fastq.gz" ] && echo "✓" || echo "✗")
    AL=$([ -f "${OUTPUT_BASE}/bams/${SRR}_Aligned.sortedByCoord.out.bam" ] && echo "✓" || echo "✗")
    CV=$([ -f "${OUTPUT_BASE}/results/${SRR}_coverage_summary.txt" ] && echo "✓" || echo "✗")
    
    printf "%-15s %-10s %-10s %-10s %-10s %-10s\n" "$SRR" "$DL" "$DL" "$TR" "$AL" "$CV"
done < "${WORK_BASE}/SRR-ids.txt"

echo ""
echo "Running jobs:"
squeue -u $USER -o "%.18i %.9P %.30j %.8T %.10M %.6D"
