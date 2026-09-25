#!/bin/bash
#SBATCH --job-name=star_smallRNA
#SBATCH --output=logs/align_smallRNA_%A_%a.out
#SBATCH --error=logs/align_smallRNA_%A_%a.err
#SBATCH --array=0-1
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=4:00:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

ml star samtools

FASTQDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE56152/fastq"
GENOMEDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/references/STARIndex_ucsc_hg38"
OUTDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE56152/bams"

SRA_IDS=(SRR1203788 SRR1203794)
SRR=${SRA_IDS[$SLURM_ARRAY_TASK_ID]}

echo "Aligning small RNA sample: $SRR"
date

# Small RNA-specific STAR parameters
STAR --runThreadN 8 \
     --genomeDir ${GENOMEDIR} \
     --readFilesIn ${FASTQDIR}/${SRR}.fastq.gz \
     --readFilesCommand zcat \
     --outFilterMatchNmin 16 \
     --outFilterMismatchNmax 1 \
     --outFilterMultimapNmax 20 \
     --alignIntronMax 1 \
     --alignEndsType EndToEnd \
     --outSAMtype BAM SortedByCoordinate \
     --outSAMattributes All \
     --outFileNamePrefix ${OUTDIR}/${SRR}_smallRNA_

samtools index ${OUTDIR}/${SRR}_smallRNA_Aligned.sortedByCoord.out.bam

echo "Completed $SRR"
date
