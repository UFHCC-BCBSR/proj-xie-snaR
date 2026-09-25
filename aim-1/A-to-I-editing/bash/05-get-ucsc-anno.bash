#!/bin/bash
ANNODIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/AnnotationAndRegions"

# Download common SNPs (dbSNP)
wget -O ${ANNODIR}/ucscHg38CommonSNPs.bed.gz \
  "http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/snp151Common.txt.gz"

# Download RefSeq genes
wget -O ${ANNODIR}/ucscHg38RefSeq.bed.gz \
  "http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/ncbiRefSeqCurated.txt.gz"

# Download Alu repeats
wget -O ${ANNODIR}/ucscHg38Alu.bed.gz \
  "http://hgdownload.soe.ucsc.edu/goldenPath/hg38/database/rmsk.txt.gz"

# Convert refseq genes to expected format
# Convert the raw UCSC table to the 8-column format the tool expects
zcat ${ANNODIR}/ucscHg38RefSeq.bed.gz | \
awk 'BEGIN{OFS="\t"} {print $3, $5, $6, $2, $13, $4, $10, $11}' | \
gzip > ${ANNODIR}/ucscHg38RefSeq.converted.bed.gz

# Verify the output matches the test format
zcat ${ANNODIR}/ucscHg38RefSeq.converted.bed.gz | head -5

# More changes to force compatibility

# Create a chr19 test RefSeq file matching the working format
zcat /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/AnnotationAndRegions/ucscHg38RefSeqCurated.OnlyChr1.bed.gz | head -1 > /tmp/header_example.txt

# Manually create chr19 entries using the same format
# Extract chr19 genes from your original UCSC download and convert:
zcat ${ANNODIR}/ucscHg38RefSeq.bed.gz | \
awk 'BEGIN{OFS="\t"} $3=="chr19" {print $3, $5, $6, $2, $13, $4, $10, $11}' | \
gzip > ${ANNODIR}/ucscHg38RefSeq.chr19only.bed.gz

# Verify it matches test format
echo "=== chr19 file ==="
zcat ${ANNODIR}/ucscHg38RefSeq.chr19only.bed.gz | head -2

echo "=== Test file format ==="
zcat /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/AnnotationAndRegions/ucscHg38RefSeqCurated.OnlyChr1.bed.gz | head -2
