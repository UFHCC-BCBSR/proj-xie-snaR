#!/bin/bash
#SBATCH --job-name=align
#SBATCH --output=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/04_align_%A_%a.log
#SBATCH --error=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/04_align_%A_%a.err
#SBATCH --array=0-3
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=12:00:00
#SBATCH --account=cancercenter-dept	
#SBATCH --qos=cancercenter-dept-b

ml star samtools

TRIM_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/fastq_trimmed"
BAM_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/bams"
GENOME_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/references/STARIndex_ucsc_hg38"

# Get list of all _1.trimmed.fastq.gz files and extract sample names
cd ${TRIM_DIR}
SAMPLES=($(ls *_1.trimmed.fastq.gz | sed 's/_1.trimmed.fastq.gz//'))

# Get the sample for this array task
SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

echo "=========================================="
echo "Aligning sample: ${SAMPLE}"
echo "Array task ID: ${SLURM_ARRAY_TASK_ID}"
echo "Start time: $(date)"
echo "=========================================="

STAR --runThreadN 8 \
     --genomeDir ${GENOME_DIR} \
     --readFilesIn ${TRIM_DIR}/${SAMPLE}_1.trimmed.fastq.gz ${TRIM_DIR}/${SAMPLE}_2.trimmed.fastq.gz \
     --readFilesCommand zcat \
     --outFilterMultimapNmax 20 \
     --outFilterMismatchNmax 10 \
     --outFilterMismatchNoverReadLmax 0.07 \
     --alignIntronMin 1000000 \
     --alignIntronMax 1 \
     --seedSearchStartLmax 20 \
     --outFilterScoreMinOverLread 0.66 \
     --outFilterMatchNminOverLread 0.66 \
     --outSAMtype BAM SortedByCoordinate \
     --outSAMattributes All \
     --outFileNamePrefix ${BAM_DIR}/${SAMPLE}_

echo "Indexing BAM..."
samtools index ${BAM_DIR}/${SAMPLE}_Aligned.sortedByCoord.out.bam

echo "Completed: ${SAMPLE}"
echo "End time: $(date)"
