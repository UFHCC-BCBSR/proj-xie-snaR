#!/bin/bash
ml samtools
for bam in /orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/aligned/GSE99249_ucsc/*.bam; do
  echo "======== Processing $bam ========"
  zcat /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/AnnotationAndRegions/ucscHg38Alu.OnlyChr1.bed.gz | while read chr start end rest; do
    echo "=== ${chr}:${start}-${end} ==="
    samtools view -c $bam ${chr}:${start}-${end}
    samtools view $bam ${chr}:${start}-${end} | awk '{if(and($2,16)) print "reverse"; else print "forward"}' | sort | uniq -c
  done
done
