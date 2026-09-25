ml singularity

# Container and directories
CONTAINER="/blue/cancercenter-dept/tools/containers/rnaeditingindexer.sif"
BAMDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/aligned/GSE99249_ucsc/"
TESTRESOURCES="/blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources"
GENOMEDIR="/orange/cancercenter-dept/GENOMES/iGenomes/references/Homo_sapiens/Ensembl/GRCh38/Sequence/WholeGenomeFasta"
TESTDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/AEI_crosstest"

mkdir -p ${TESTDIR}/{logs,tmp,output}

# Start container shell
singularity shell \
    --bind ${BAMDIR}:/bams:ro \
    --bind ${TESTRESOURCES}:/testdata:ro \
    --bind ${GENOMEDIR}:/genome:ro \
    --bind ${TESTDIR}:/data:rw \
    ${CONTAINER}

# Then run this INSIDE the container:
RNAEditingIndex \
    -d /bams \
    -f SRR5564268_Aligned.sortedByCoord.out.bam \
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
