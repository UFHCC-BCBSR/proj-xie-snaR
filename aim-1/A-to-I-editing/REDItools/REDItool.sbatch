#!/bin/bash
#SBATCH --job-name=reditools
#SBATCH --output=reditools_%A_%a.log
#SBATCH --array=0-6     # number of BAM files
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4     # REDItools can use multiple cores
#SBATCH --mem=32gb             # Start here, increase if needed
#SBATCH --time=24:00:00        # 8 hours, adjust as needed
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

# Load environment
module load conda
conda activate reditools

# Get list of BAM files
BAM_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/aligned/GSE99249_ucsc/"
BAM_FILES=(${BAM_DIR}*.bam)
BAM=${BAM_FILES[$SLURM_ARRAY_TASK_ID]}
REF="/orange/cancercenter-dept/GENOMES/iGenomes/references/Homo_sapiens/Ensembl/GRCh38/Sequence/WholeGenomeFasta/ucscHg38Genome.fa"

filename=$(basename "$BAM" .bam)
echo "Processing $filename..."

# Run REDItools with region restriction
reditools2.0 \
    -f "$BAM" \
    -r "$REF" \
    -R snaR-A_hg38.refseq_format.6.bed.gz \
    -o "reditools_results/${filename}.RES.tsv" \
    -t 4  # Use 4 threads
