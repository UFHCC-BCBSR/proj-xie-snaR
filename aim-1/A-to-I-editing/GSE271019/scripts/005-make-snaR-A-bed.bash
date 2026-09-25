#!/bin/bash
# Create bed file based on https://doi.org/10.1093/nar/gkm668 Table 1 Subset A
# Create directory structure
ANNODIR="/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/AnnotationAndRegions/"
mkdir -p ${ANNODIR}

# Create snaR-A BED6 file (with strand info)
cat > ${ANNODIR}/snaR-A_hg38.bed << 'EOF'
chr19   53102747        53102864        snaR-A_1        .       +
chr19   53113498        53113615        snaR-A_2        .       +
chr19   53118848        53118965        snaR-A_3        .       +
chr19   53129250        53129367        snaR-A_4        .       +
chr19   53139991        53140108        snaR-A_5        .       +
chr19   55287678        55287795        snaR-A_6        .       -
chr19   55293015        55293132        snaR-A_7        .       -
chr19   55296080        55296197        snaR-A_8        .       -
chr19   55299144        55299261        snaR-A_9        .       -
chr19   55302203        55302320        snaR-A_10       .       -
chr19   55307557        55307674        snaR-A_11       .       -
chr19   55312909        55313026        snaR-A_12       .       -
chr19   55318263        55318380        snaR-A_13       .       -
chr19   55323591        55323708        snaR-A_14       .       -
EOF

# Sort, compress and index BED6 (full format with strand)
sort -k1,1 -k2,2n ${ANNODIR}/snaR-A_hg38.bed > ${ANNODIR}/snaR-A_hg38.sorted.bed
bgzip ${ANNODIR}/snaR-A_hg38.sorted.bed
tabix -p bed ${ANNODIR}/snaR-A_hg38.sorted.bed.gz

# Create BED3 format (only first 3 columns for pipeline)
cut -f1-3 ${ANNODIR}/snaR-A_hg38.bed | sort -k1,1 -k2,2n > ${ANNODIR}/snaR-A_hg38.bed3.bed
bgzip ${ANNODIR}/snaR-A_hg38.bed3.bed
tabix -p bed ${ANNODIR}/snaR-A_hg38.bed3.bed.gz

# Verify it worked
echo "=== BED6 (with strand) ==="
ls -lh ${ANNODIR}/snaR-A_hg38.sorted.bed.gz*
zcat ${ANNODIR}/snaR-A_hg38.sorted.bed.gz | head -5

echo ""
echo "=== BED3 (for pipeline) ==="
ls -lh ${ANNODIR}/snaR-A_hg38.bed3.bed.gz*
zcat ${ANNODIR}/snaR-A_hg38.bed3.bed.gz | head -5
