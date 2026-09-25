#!/bin/bash
#SBATCH --job-name=coverage
#SBATCH --output=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/05_coverage_%x_%j.log
#SBATCH --error=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/05_coverage_%x_%j.err
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=2:00:00
#SBATCH --account=mingyi.xie
#SBATCH --qos=mingyi.xie-b

ml bedtools samtools

BAM_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/bams"
RESULTS_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/results"
SNAR_BED="/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/AnnotationAndRegions/snaR-A_hg38.sorted.bed.gz"

echo "=========================================="
echo "Calculating snaR-A coverage for ${SRR}"
echo "Start time: $(date)"
echo "=========================================="

BAM="${BAM_DIR}/${SRR}_Aligned.sortedByCoord.out.bam"
OUT="${RESULTS_DIR}/${SRR}_snaR-A_coverage.txt"
SUMMARY="${RESULTS_DIR}/${SRR}_coverage_summary.txt"

# Calculate coverage
bedtools coverage -a ${SNAR_BED} -b ${BAM} > ${OUT}

# Generate summary
echo "=== Coverage Summary for ${SRR} ===" > ${SUMMARY}
echo "Date: $(date)" >> ${SUMMARY}
echo "" >> ${SUMMARY}
echo "Total snaR-A loci: $(zcat ${SNAR_BED} | wc -l)" >> ${SUMMARY}
echo "Loci with coverage >0: $(awk '$4 > 0' ${OUT} | wc -l)" >> ${SUMMARY}
echo "Loci with coverage >=10: $(awk '$4 >= 10' ${OUT} | wc -l)" >> ${SUMMARY}
echo "" >> ${SUMMARY}
echo "Mean coverage: $(awk '{sum+=$4; count++} END {printf \"%.2f\n\", sum/count}' ${OUT})" >> ${SUMMARY}
echo "Median coverage: $(sort -k4,4n ${OUT} | awk '{a[NR]=$4} END {if(NR%2==1) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2}')" >> ${SUMMARY}
echo "Max coverage: $(sort -k4,4n ${OUT} | tail -1 | awk '{print $4}')" >> ${SUMMARY}

cat ${SUMMARY}

echo ""
echo "Completed: ${SRR}"
echo "End time: $(date)"
