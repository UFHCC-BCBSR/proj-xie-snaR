#!/bin/bash
ml samtools

# Separate bed file by strand
zcat ../references/snaR-A_hg38.sorted.bed.gz | awk '$6=="+"' > snaR-A_plus.bed
zcat ../references/snaR-A_hg38.sorted.bed.gz | awk '$6=="-"' > snaR-A_minus.bed

for bam in ../data/bams/*.bam; do
    sample=$(basename $bam _Aligned.sortedByCoord.out.bam)
    echo "=== $sample ==="
    echo "Plus strand regions:"
    while read chr start end name score strand; do
        count=$(samtools view -c -F 16 $bam ${chr}:${start}-${end})
        echo -e "${name}\t${count}"
    done < snaR-A_plus.bed
    echo ""
    echo "Minus strand regions:"
    while read chr start end name score strand; do
        count=$(samtools view -c -f 16 $bam ${chr}:${start}-${end})
        echo -e "${name}\t${count}"
    done < snaR-A_minus.bed
    echo ""
done
