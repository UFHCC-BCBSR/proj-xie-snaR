#!/bin/bash
#SBATCH --job-name=star_align
#SBATCH --output=logs/align_%A_%a.out
#SBATCH --error=logs/align_%A_%a.err
#SBATCH --array=0-0
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=12:00:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

ml star samtools

#FASTQDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE271019/fastq"
TRIMDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE271019/fastq_trimmed"
GENOMEDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/references/STARIndex_ucsc_hg38"
OUTDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE271019/bams"
GTF="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/references/Homo_sapiens.GRCh38.112.ucsc.gtf"

mkdir -p ${OUTDIR}
mkdir -p logs

# Define variables
SRR="SRR29637065"
FASTQDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE271019/fastq"

# STAR alignment for paired-end RNA-seq
# STAR alignment for paired-end short ncRNA (120 nt, no splicing)
STAR --runThreadN 8 \
     --genomeDir ${GENOMEDIR} \
     --readFilesIn ${TRIMDIR}/${SRR}_1.trimmed.fastq.gz ${TRIMDIR}/${SRR}_2.trimmed.fastq.gz \
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
     --outFileNamePrefix ${OUTDIR}/${SRR}_

samtools index ${OUTDIR}/${SRR}_Aligned.sortedByCoord.out.bam
echo "Completed $SRR"
date

