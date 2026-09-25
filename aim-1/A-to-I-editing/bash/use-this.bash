[hkates@c0709a-s30 bash]$ singularity exec \
  --bind /orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/aligned/GSE99249_ucsc/:/bams:ro \
  --bind /orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/AnnotationAndRegions:/annotations:ro \
  --bind /orange/cancercenter-dept/GENOMES/iGenomes/references/Homo_sapiens/Ensembl/GRCh38/Sequence/WholeGenomeFasta:/genome:ro \
  --bind $(pwd)/test-works-my-data-test-ref:/data:rw \
  "/blue/cancercenter-dept/tools/containers/rnaeditingindexer.sif" \
  RNAEditingIndex \
    -d /bams \
    -f SRR5564268_Aligned.sortedByCoord.out.bam \
    -l /data/logs \
    -o /data/tmp \
    -os /data/output \
    --genome hg38 \
    --genome_fasta /genome/ucscHg38Genome.fa \
    -rb /annotations/snaR-A_hg38.sorted.bed3.gz \
    --keep_cmpileup \
    --verbose \
    --paired
WARNING: underlay of /usr/share/zoneinfo/Etc/UTC required more than 50 (81) bind mounts
Arguments in effect:
        Input file : /data/tmp/_region_snaR-A_hg38.sorted.bed3.gz_alignments.bam
        Output file : /data/tmp/_region_snaR-A_hg38.sorted.bed3.gz_alignments.bam.trimmed_5.bam
        #Bases to trim from each side : 5

Number of records read = 0
Number of records written = 0
[mpileup] 1 samples in 1 input files
GenerateIndex - Starting!
Running: bedtools getfasta -name -bedOut -fi '/genome/ucscHg38Genome.fa' -bed '/annotations/snaR-A_hg38.sorted.bed3.gz'
GenerateIndex - Indexing FASTA Records!
GenerateIndex - Done Converting, Outputted to /data/tmp/ucscHg38Genome.fa.GenomeIndex.jsd
[2025-12-11 15:52:07,518] general_functions WARNING  GGPSResources.general_functions.remove_files Failed To Remove 11-12-2025-20.cn
[2025-12-11 15:52:07,518] general_functions WARNING  GGPSResources.general_functions.remove_files Failed To Remove 11-12-2025-20.cn
[hkates@c0709a-s30 bash]$ ls
001-dl-RNA-editing-indexer.bash         04-make-snaR-A-bed.sbatch               logs/
002-build-sif.sbatch                    05b-convert-bams-to-ucsc.bash           log.tmp.txt
003-test-sif.sbatch                     05-get-ucsc-anno.bash                   save-commands.bash
01-GSM-to-SRR.bash                      06b-test-RNAEditingIndexer-snaR-A.bash  srr-list.txt
02-download-fasterq.sbatch              06-run-RNAEditingIndexer-snaR-A.bash    test-works-my-data-test-ref/
02-download-fastq.sbatch                gsm_list.txt
03-align.sbatch                         gsm_srr_mapping.csv
[hkates@c0709a-s30 bash]$ ls test-works-my-data-test-ref/output/EditingIndex.csv ^C
