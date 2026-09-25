ml singularity

# Container
CONTAINER="/blue/cancercenter-dept/tools/containers/rnaeditingindexer.sif"

# Data directories
#BAMDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/aligned/GSE99249"
BAMDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/aligned/GSE99249_ucsc/"
ANNOTDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/AnnotationAndRegions"
GENOMEDIR="/orange/cancercenter-dept/GENOMES/iGenomes/references/Homo_sapiens/Ensembl/GRCh38/Sequence/WholeGenomeFasta"

# Output directories
# snaR run output
SNAR_WORKDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/editing_index_snaR"
mkdir -p ${SNAR_WORKDIR}/{logs,tmp,output}

# Launch and run
singularity shell \
    --bind ${BAMDIR}:/bams:ro \
    --bind ${ANNOTDIR}:/annotations:ro \
    --bind ${GENOMEDIR}:/bin/AEI/RNAEditingIndexer/Resources/Genomes/HomoSapiens:rw \
    --bind ${SNAR_WORKDIR}:/data:rw \
    ${CONTAINER} \

# Then Run
    RNAEditingIndex \
    -d /bams \
    -f SRR5564268_Aligned.sortedByCoord.out.bam \
    -l /data/logs \
    -o /data/tmp \
    -os /data/output \
    --genome hg38 \
    --genome_fasta /bin/AEI/RNAEditingIndexer/Resources/Genomes/HomoSapiens/ucscHg38Genome.fa \
    -rb /annotations/snaR-A_hg38.sorted.bed.gz \
    --snps /annotations/ucscHg38CommonSNPs.bed.gz \
    --verbose \
    --stranded \
    --paired_end
#    --refseq /annotations/ucscHg38RefSeq.bed.gz \
#     --refseq /annotations/ucscHg38RefSeq.chr19only.bed.gz \



echo "snaR-A analysis complete! Results in: ${SNAR_WORKDIR}/output"

# Then Run with built in resources
    RNAEditingIndex \
    -d /bams \
    -f _Aligned.sortedByCoord.out.bam \
    -l /data/logs \
    -o /data/tmp \
    -os /data/output \
    --genome hg38 \
    --verbose \
    --stranded \
    --paired_end

