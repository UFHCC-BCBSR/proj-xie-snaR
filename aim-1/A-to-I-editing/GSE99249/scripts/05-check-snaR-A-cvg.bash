#!/bin/bash
ml samtools

for bam in /orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/aligned/GSE99249_ucsc/*bam; do echo "=== $(basename $bam) ==="; samtools bedcov /blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/AnnotationAndRegions/snaR-A_hg38.sorted.tab.bed.gz "$bam"; done
