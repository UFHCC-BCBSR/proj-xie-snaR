#!/bin/bash
#SBATCH --job-name=test_aei_container
#SBATCH --output=logs/test_aei.out
#SBATCH --error=logs/test_aei.err
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=00:30:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

ml singularity

CONTAINER="/blue/cancercenter-dept/tools/containers/rnaeditingindexer.sif"
#TESTDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/AEI_test"
TESTDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/AEI_test2"
TESTRESOURCES="/blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources"
GENOMEDIR="/orange/cancercenter-dept/GENOMES/iGenomes/references/Homo_sapiens/Ensembl/GRCh38/Sequence/WholeGenomeFasta"

mkdir -p ${TESTDIR}/{logs,tmp,output}

echo "Running RNAEditingIndexer built-in test..."
date

singularity exec \
    --bind ${TESTDIR}:/data:rw \
    --bind ${TESTRESOURCES}:/testdata:ro \
    --bind ${GENOMEDIR}:/genome:ro \
    ${CONTAINER} \
    RNAEditingIndex \
        -d /testdata/BAMs \
        -f _sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam \
        -l /data/logs \
        -o /data/tmp \
        -os /data/output \
        --genome hg38 \
        --genome_fasta /genome/ucscHg38Genome.fa \
        -rb /testdata/AnnotationAndRegions/ucscHg38Alu.OnlyChr1.bed.gz \
        --refseq /testdata/AnnotationAndRegions/ucscHg38RefSeqCurated.OnlyChr1.bed.gz \
        --snps /testdata/AnnotationAndRegions/ucscHg38CommonGenomicSNPs150.OnlyChr1.bed.gz \
        --genes_expression /testdata/AnnotationAndRegions/ucscHg38GTExGeneExpression.OnlyChr1.bed.gz \
        --verbose \
        --stranded \
        --paired

echo "Test complete! Check output:"
echo "${TESTDIR}/output/"
date
