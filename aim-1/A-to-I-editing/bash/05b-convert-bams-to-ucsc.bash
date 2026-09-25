#!/bin/bash

ml samtools

CONVERTED_BAMDIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/aligned/GSE99249_ucsc"
mkdir -p ${CONVERTED_BAMDIR}

for bam in /orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/aligned/GSE99249/*.bam; do
    sample=$(basename ${bam})
    echo "Converting ${sample}..."
    
    # Extract header, add "chr", rebuild with tabs preserved
    samtools view -H ${bam} | sed 's/SN:\([0-9XYM]\)/SN:chr\1/g; s/SN:MT/SN:chrMT/g' > ${CONVERTED_BAMDIR}/header.sam
    
    # Combine new header with reads
    samtools reheader ${CONVERTED_BAMDIR}/header.sam ${bam} > ${CONVERTED_BAMDIR}/${sample}
    
    # Index
    samtools index ${CONVERTED_BAMDIR}/${sample}
done

# Clean up temporary header
rm ${CONVERTED_BAMDIR}/header.sam

echo "Conversion complete!"
