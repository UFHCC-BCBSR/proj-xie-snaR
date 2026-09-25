#!/bin/bash
#SBATCH --job-name=star_index
#SBATCH --output=logs/star_index_%j.log
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=04:00:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

ml star

# Paths
REFDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/references"
GENOMEDIR="${REFDIR}/STARIndex_ucsc_hg38"
GENOMEFASTA="/orange/cancercenter-dept/GENOMES/iGenomes/references/Homo_sapiens/Ensembl/GRCh38/Sequence/WholeGenomeFasta/ucscHg38Genome.fa"
INPUT_GTF="/orange/cancercenter-dept/GENOMES/iGenomes/references/Homo_sapiens/Ensembl/GRCh38/Annotation/Genes/Homo_sapiens.GRCh38.112.gtf"
UCSC_GTF="${REFDIR}/Homo_sapiens.GRCh38.112.ucsc.gtf"

mkdir -p ${REFDIR}
mkdir -p ${GENOMEDIR}

# Convert GTF to UCSC format (add "chr" prefix)
echo "Converting GTF to UCSC format..."
date
awk 'BEGIN{OFS="\t"} {if($0 !~ /^#/) {$1="chr"$1} print}' $INPUT_GTF > $UCSC_GTF
echo "GTF conversion complete"
wc -l $INPUT_GTF $UCSC_GTF

# Build STAR index
echo "Building STAR index..."
date
STAR --runMode genomeGenerate \
     --runThreadN 16 \
     --genomeDir ${GENOMEDIR} \
     --genomeFastaFiles ${GENOMEFASTA} \
     --sjdbGTFfile ${UCSC_GTF} \
     --sjdbOverhang 99

echo "STAR index build complete"
date
