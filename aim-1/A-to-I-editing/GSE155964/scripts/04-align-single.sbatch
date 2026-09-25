#!/bin/bash
#SBATCH --job-name=align
#SBATCH --output=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/04_align_%x_%j.log
#SBATCH --error=/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/04_align_%x_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=12:00:00
#SBATCH --account=mingyi.xie
#SBATCH --qos=mingyi.xie-b

ml star samtools

TRIM_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/fastq_trimmed"
BAM_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/bams"
GENOME_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/references/STARIndex_ucsc_hg38"

echo "=========================================="
echo "Aligning ${SRR}"
echo "Start time: $(date)"
echo "=========================================="

STAR --runThreadN 8 \
     --genomeDir ${GENOME_DIR} \
     --readFilesIn ${TRIM_DIR}/${SRR}_1.trimmed.fastq.gz ${TRIM_DIR}/${SRR}_2.trimmed.fastq.gz \
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
     --outFileNamePrefix ${BAM_DIR}/${SRR}_

echo "Indexing BAM..."
samtools index ${BAM_DIR}/${SRR}_Aligned.sortedByCoord.out.bam

echo "Completed: ${SRR}"
echo "End time: $(date)"
