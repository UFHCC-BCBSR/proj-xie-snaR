ml singularity

# Set Variables
  
CONTAINER="/blue/cancercenter-dept/tools/containers/rnaeditingindexer.sif"
TESTDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/AEI_test"
TESTRESOURCES="/blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources"
GENOMEDIR="/orange/cancercenter-dept/GENOMES/iGenomes/references/Homo_sapiens/Ensembl/GRCh38/Sequence/WholeGenomeFasta"

  
mkdir -p ${TESTDIR}/{logs,tmp,output}


# Verify the files are there
ls -lh ${GENOMEDIR}/ucscHg38Genome.fa*

# Launch container (same as before)
singularity shell \
    --bind ${TESTDIR}:/data:rw \
    --bind ${TESTRESOURCES}:/testdata:rw \
    --bind ${GENOMEDIR}:/bin/AEI/RNAEditingIndexer/Resources/Genomes/HomoSapiens:rw \
    ${CONTAINER}

# Inside container - clean and run
Singularity> rm -rf /data/logs/* /data/tmp/* /data/output/*

Singularity> RNAEditingIndex \
    -d /testdata/BAMs \
    -f _sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam \
    -l /data/logs \
    -o /data/tmp \
    -os /data/output \
    --genome hg38 \
    -rb /testdata/AnnotationAndRegions/ucscHg38Alu.OnlyChr1.bed.gz \
    --refseq /testdata/AnnotationAndRegions/ucscHg38RefSeqCurated.OnlyChr1.bed.gz \
    --snps /testdata/AnnotationAndRegions/ucscHg38CommonGenomicSNPs150.OnlyChr1.bed.gz \
    --genes_expression /testdata/AnnotationAndRegions/ucscHg38GTExGeneExpression.OnlyChr1.bed.gz \
    --verbose \
    --stranded \
    --paired
