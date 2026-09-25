#!/bin/bash
#SBATCH --job-name=star_align
#SBATCH --output=logs/align_%A_%a.out
#SBATCH --error=logs/align_%A_%a.err
#SBATCH --array=0-3
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=12:00:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

ml star samtools

FASTQDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE56152/fastq"
GENOMEDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/references/STARIndex_ucsc_hg38"
OUTDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE56152/bams"
GTF="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/references/Homo_sapiens.GRCh38.112.ucsc.gtf"

mkdir -p ${OUTDIR}
mkdir -p logs

# Array of SRA IDs
SRA_IDS=(SRR1203776 SRR1203782 SRR1203788 SRR1203794)
SRR=${SRA_IDS[$SLURM_ARRAY_TASK_ID]}

echo "Aligning $SRR"
date

# Single-end alignment
STAR --runThreadN 8 \
     --genomeDir ${GENOMEDIR} \
     --readFilesIn ${FASTQDIR}/${SRR}.fastq.gz \
     --readFilesCommand zcat \
     --outFilterMatchNminOverLread 0.95 \
     --sjdbGTFfile ${GTF} \
     --outSAMtype BAM SortedByCoordinate \
     --outSAMattributes All \
     --quantMode GeneCounts \
     --outFileNamePrefix ${OUTDIR}/${SRR}_

# Index the BAM file
echo "Indexing ${SRR}_Aligned.sortedByCoord.out.bam"
samtools index ${OUTDIR}/${SRR}_Aligned.sortedByCoord.out.bam

echo "Completed $SRR"
date
