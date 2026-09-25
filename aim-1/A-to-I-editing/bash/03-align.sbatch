#!/bin/bash
#SBATCH --job-name=star_align
#SBATCH --output=logs/align_%A_%a.out
#SBATCH --error=logs/align_%A_%a.err
#SBATCH --array=6-6
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=24:00:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

ml star

FASTQDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/raw-data/GSE99249"
GENOMEDIR="/orange/cancercenter-dept/GENOMES/iGenomes/references/Homo_sapiens/Ensembl/GRCh38/Sequence/STARIndex/rsem"
OUTDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/aligned/GSE99249"

mkdir -p ${OUTDIR}

SRR=$(sed -n "${SLURM_ARRAY_TASK_ID}p" srr-list.txt)

echo "Aligning $SRR"
date

STAR --runThreadN 8 \
     --genomeDir ${GENOMEDIR} \
     --readFilesIn ${FASTQDIR}/${SRR}_1.fastq.gz ${FASTQDIR}/${SRR}_2.fastq.gz \
     --readFilesCommand zcat \
     --outFilterMatchNminOverLread 0.95 \
     --outSAMtype BAM SortedByCoordinate \
     --outSAMattributes All \
     --outFileNamePrefix ${OUTDIR}/${SRR}_

echo "Completed $SRR"
date

## NOT RUN BUT SHOULD BE ADDEDED TO ASSEMBLY IN FUTURE
# Load samtools if not already available
#module load samtools

# Index all BAM files
#for bam in /orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/aligned/GSE99249/*_Aligned.sortedByCoord.out.bam; do
#    echo "Indexing $bam"
#    samtools index $bam
#done

# Verify indices were created
#ls -lh /orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/aligned/GSE99249/*.bai
