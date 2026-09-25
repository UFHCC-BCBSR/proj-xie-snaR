# Pick a few Alu regions from the test data
zcat /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/AnnotationAndRegions/ucscHg38Alu.OnlyChr1.bed.gz | head -5

# For each region, check total reads and strand distribution
# Region 1: chr1:26790-27053
echo "=== Region chr1:26790-27053 ==="
samtools view -c /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:26790-27053
echo "Strand 1 (Read2, not rev OR Read1, mate rev):"
samtools view -f 128 -F 16 /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:26790-27053 | wc -l
samtools view -f 80 /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:26790-27053 | wc -l
echo "Strand 2 (Read1, rev OR Read2, not rev, mate rev):"
samtools view -f 144 /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:26790-27053 | wc -l
samtools view -f 64 -F 16 /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:26790-27053 | wc -l

# Region 2: chr1:31435-31733
echo "=== Region chr1:31435-31733 ==="
samtools view -c /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:31435-31733
echo "Strand 1:"
samtools view -f 128 -F 16 /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:31435-31733 | wc -l
samtools view -f 80 /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:31435-31733 | wc -l
echo "Strand 2:"
samtools view -f 144 /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:31435-31733 | wc -l
samtools view -f 64 -F 16 /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:31435-31733 | wc -l

# Region 3: chr1:51584-51880
echo "=== Region chr1:51584-51880 ==="
samtools view -c /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:51584-51880
echo "Strand 1:"
samtools view -f 128 -F 16 /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:51584-51880 | wc -l
samtools view -f 80 /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:51584-51880 | wc -l
echo "Strand 2:"
samtools view -f 144 /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:51584-51880 | wc -l
samtools view -f 64 -F 16 /blue/cancercenter-dept/tools/RNAEditingIndexer/TestResources/BAMs/BAMs/SRR5962201/SRR5962201_sampled_with_0.1.Aligned.sortedByCoord.out.bam.AluChr1Only.bam chr1:51584-51880 | wc -l
