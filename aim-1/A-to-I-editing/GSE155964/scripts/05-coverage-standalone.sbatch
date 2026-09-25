#!/bin/bash
#SBATCH --job-name=coverage
#SBATCH --output=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/05_coverage_%x_%A_%a.log
#SBATCH --error=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/05_coverage_%x_%A_%a.err
#SBATCH --array=0-3  # Number of bam files
#SBATCH --cpus-per-task=1
#SBATCH --mem=64G
#SBATCH --time=2:00:00
#SBATCH --account=mingyi.xie
#SBATCH --qos=mingyi.xie-b

ml bedtools samtools

BAM_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/bams"
RESULTS_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/results"
#SNAR_BED="/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/AnnotationAndRegions/snaR-A_hg38.sorted.bed.gz"
SNAR_BED="/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/AnnotationAndRegions/snaR-A_hg38.sorted.tab.bed.gz"

# Create array of BAM files
BAM_FILES=(${BAM_DIR}/*_Aligned.sortedByCoord.out.bam)

# Get the BAM file for this task
BAM="${BAM_FILES[$SLURM_ARRAY_TASK_ID]}"

# Extract sample name from BAM filename
SAMPLE=$(basename ${BAM} _Aligned.sortedByCoord.out.bam)

echo "=========================================="
echo "Calculating snaR-A coverage for ${SAMPLE}"
echo "Start time: $(date)"
echo "=========================================="

OUT="${RESULTS_DIR}/${SAMPLE}_snaR-A_coverage.txt"
SUMMARY="${RESULTS_DIR}/${SAMPLE}_coverage_summary.txt"

# Calculate coverage
bedtools coverage -a ${SNAR_BED} -b ${BAM} > ${OUT}

# Generate summary
echo "=== Coverage Summary for ${SAMPLE} ===" > ${SUMMARY}
echo "Date: $(date)" >> ${SUMMARY}
echo "" >> ${SUMMARY}
echo "Total snaR-A loci: $(zcat ${SNAR_BED} | wc -l)" >> ${SUMMARY}
echo "Loci with coverage >0: $(awk '$4 > 0' ${OUT} | wc -l)" >> ${SUMMARY}
echo "Loci with coverage >=10: $(awk '$4 >= 10' ${OUT} | wc -l)" >> ${SUMMARY}
echo "" >> ${SUMMARY}
echo "Mean coverage: $(awk '{sum+=$4; count++} END {printf "%.2f\n", sum/count}' ${OUT})" >> ${SUMMARY}
echo "Median coverage: $(sort -k4,4n ${OUT} | awk '{a[NR]=$4} END {if(NR%2==1) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2}')" >> ${SUMMARY}
echo "Max coverage: $(sort -k4,4n ${OUT} | tail -1 | awk '{print $4}')" >> ${SUMMARY}

cat ${SUMMARY}
echo ""
echo "Completed: ${SAMPLE}"
echo "End time: $(date)"
