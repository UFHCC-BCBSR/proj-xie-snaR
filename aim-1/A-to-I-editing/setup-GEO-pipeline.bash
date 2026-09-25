#!/bin/bash
# setup_pipeline.sh
# Usage: ./setup_pipeline.sh <GSE_ID> <SRR_list.txt>

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <GSE_ID> <SRR_list.txt>"
    echo "Example: $0 GSE155964 SRR-ids.txt"
    exit 1
fi

GSE_ID=$1
SRR_LIST=$2

if [ ! -f "$SRR_LIST" ]; then
    echo "Error: SRR list file '$SRR_LIST' not found"
    exit 1
fi

# Setup directories - outputs to /orange, scripts/working on /blue
OUTPUT_BASE="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/${GSE_ID}"
WORK_BASE="/blue/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/${GSE_ID}"

# Create directory structure
mkdir -p ${OUTPUT_BASE}/{fastq,fastq_trimmed,bams,fastp_reports,results}
mkdir -p ${WORK_BASE}/{scripts,logs}

SCRIPT_DIR="${WORK_BASE}/scripts"
LOG_DIR="${WORK_BASE}/logs"

echo "Setting up pipeline for ${GSE_ID}"
echo "Working directory: ${WORK_BASE}"
echo "Output directory: ${OUTPUT_BASE}"

# Reference paths
REF_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/references"
GENOME_DIR="${REF_DIR}/STARIndex_ucsc_hg38"
SNAR_BED="${REF_DIR}/snaR-A_hg38.sorted.bed.gz"

# Create download script
cat > ${SCRIPT_DIR}/01-download-single.sbatch << EOF
#!/bin/bash
#SBATCH --job-name=download
#SBATCH --output=${LOG_DIR}/01_download_%x_%j.log
#SBATCH --time=04:00:00
#SBATCH --mem=8gb
#SBATCH --cpus-per-task=4
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept

ml sra

OUTDIR="${OUTPUT_BASE}/fastq"

echo "=========================================="
echo "Downloading \${SRR}"
echo "Start time: \$(date)"
echo "Output: \${OUTDIR}"
echo "=========================================="

fasterq-dump --split-files \\
  --outdir \${OUTDIR} \\
  --threads 4 \\
  \${SRR}

echo "Completed: \${SRR}"
echo "End time: \$(date)"
EOF

# Create compression script
cat > ${SCRIPT_DIR}/02-compress-single.sbatch << EOF
#!/bin/bash
#SBATCH --job-name=compress
#SBATCH --output=/blue/cancercenter-dept/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/logs/02_compress_%x_%j.log
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=8gb
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept

ml gcc/5.2.0
pigz/2.4

FASTQ_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/fastq"

echo "=========================================="
echo "Compressing ${SRR}"
echo "Start time: $(date)"
echo "Directory: ${FASTQ_DIR}"
echo "=========================================="

cd ${FASTQ_DIR}

for FILE in ${SRR}*.fastq; do
    if [ -f "$FILE" ]; then
        echo "Compressing $FILE with pigz..."
        pigz -p 8 "$FILE"
    fi
done

echo "Completed: ${SRR}"
echo "End time: $(date)"
EOF

# Create fastp script
cat > ${SCRIPT_DIR}/03-fastp-single.sbatch << EOF
#!/bin/bash
#SBATCH --job-name=fastp
#SBATCH --output=${LOG_DIR}/03_fastp_%x_%j.log
#SBATCH --error=${LOG_DIR}/03_fastp_%x_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=4:00:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

ml fastp

FASTQ_DIR="${OUTPUT_BASE}/fastq"
TRIM_DIR="${OUTPUT_BASE}/fastq_trimmed"
QC_DIR="${OUTPUT_BASE}/fastp_reports"

echo "=========================================="
echo "Trimming \${SRR}"
echo "Start time: \$(date)"
echo "=========================================="

fastp -i \${FASTQ_DIR}/\${SRR}_1.fastq.gz \\
      -I \${FASTQ_DIR}/\${SRR}_2.fastq.gz \\
      -o \${TRIM_DIR}/\${SRR}_1.trimmed.fastq.gz \\
      -O \${TRIM_DIR}/\${SRR}_2.trimmed.fastq.gz \\
      --detect_adapter_for_pe \\
      --thread 8 \\
      --length_required 20 \\
      --html \${QC_DIR}/\${SRR}_fastp.html \\
      --json \${QC_DIR}/\${SRR}_fastp.json

echo "Completed: \${SRR}"
echo "End time: \$(date)"
EOF

# Create alignment script
cat > ${SCRIPT_DIR}/04-align-single.sbatch << EOF
#!/bin/bash
#SBATCH --job-name=align
#SBATCH --output=${LOG_DIR}/04_align_%x_%j.log
#SBATCH --error=${LOG_DIR}/04_align_%x_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --time=12:00:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

ml star samtools

TRIM_DIR="${OUTPUT_BASE}/fastq_trimmed"
BAM_DIR="${OUTPUT_BASE}/bams"
GENOME_DIR="${GENOME_DIR}"

echo "=========================================="
echo "Aligning \${SRR}"
echo "Start time: \$(date)"
echo "=========================================="

STAR --runThreadN 8 \\
     --genomeDir \${GENOME_DIR} \\
     --readFilesIn \${TRIM_DIR}/\${SRR}_1.trimmed.fastq.gz \${TRIM_DIR}/\${SRR}_2.trimmed.fastq.gz \\
     --readFilesCommand zcat \\
     --outFilterMultimapNmax 20 \\
     --outFilterMismatchNmax 10 \\
     --outFilterMismatchNoverReadLmax 0.07 \\
     --alignIntronMin 1000000 \\
     --alignIntronMax 1 \\
     --seedSearchStartLmax 20 \\
     --outFilterScoreMinOverLread 0.66 \\
     --outFilterMatchNminOverLread 0.66 \\
     --outSAMtype BAM SortedByCoordinate \\
     --outSAMattributes All \\
     --outFileNamePrefix \${BAM_DIR}/\${SRR}_

echo "Indexing BAM..."
samtools index \${BAM_DIR}/\${SRR}_Aligned.sortedByCoord.out.bam

echo "Completed: \${SRR}"
echo "End time: \$(date)"
EOF

# Create coverage script
cat > ${SCRIPT_DIR}/05-coverage-single.sbatch << EOF
#!/bin/bash
#SBATCH --job-name=coverage
#SBATCH --output=${LOG_DIR}/05_coverage_%x_%j.log
#SBATCH --error=${LOG_DIR}/05_coverage_%x_%j.err
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=2:00:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept

ml bedtools samtools

BAM_DIR="${OUTPUT_BASE}/bams"
RESULTS_DIR="${OUTPUT_BASE}/results"
SNAR_BED="${SNAR_BED}"

echo "=========================================="
echo "Calculating snaR-A coverage for \${SRR}"
echo "Start time: \$(date)"
echo "=========================================="

BAM="\${BAM_DIR}/\${SRR}_Aligned.sortedByCoord.out.bam"
OUT="\${RESULTS_DIR}/\${SRR}_snaR-A_coverage.txt"
SUMMARY="\${RESULTS_DIR}/\${SRR}_coverage_summary.txt"

# Calculate coverage
bedtools coverage -a \${SNAR_BED} -b \${BAM} > \${OUT}

# Generate summary
echo "=== Coverage Summary for \${SRR} ===" > \${SUMMARY}
echo "Date: \$(date)" >> \${SUMMARY}
echo "" >> \${SUMMARY}
echo "Total snaR-A loci: \$(zcat \${SNAR_BED} | wc -l)" >> \${SUMMARY}
echo "Loci with coverage >0: \$(awk '\$4 > 0' \${OUT} | wc -l)" >> \${SUMMARY}
echo "Loci with coverage >=10: \$(awk '\$4 >= 10' \${OUT} | wc -l)" >> \${SUMMARY}
echo "" >> \${SUMMARY}
echo "Mean coverage: \$(awk '{sum+=\$4; count++} END {printf \"%.2f\n\", sum/count}' \${OUT})" >> \${SUMMARY}
echo "Median coverage: \$(sort -k4,4n \${OUT} | awk '{a[NR]=\$4} END {if(NR%2==1) print a[(NR+1)/2]; else print (a[NR/2]+a[NR/2+1])/2}')" >> \${SUMMARY}
echo "Max coverage: \$(sort -k4,4n \${OUT} | tail -1 | awk '{print \$4}')" >> \${SUMMARY}

cat \${SUMMARY}

echo ""
echo "Completed: \${SRR}"
echo "End time: \$(date)"
EOF

# Create the launcher script
cat > ${SCRIPT_DIR}/launch_all.sh << EOF
#!/bin/bash
# launch_all.sh - Submit pipeline for each sample independently

SCRIPT_DIR="${SCRIPT_DIR}"
LOG_DIR="${LOG_DIR}"
SRR_LIST="\$1"

if [ -z "\$SRR_LIST" ]; then
    echo "Usage: \$0 <SRR_list.txt>"
    exit 1
fi

if [ ! -f "\$SRR_LIST" ]; then
    echo "Error: File '\$SRR_LIST' not found"
    exit 1
fi

echo "=========================================="
echo "Launching pipeline for all samples"
echo "Working directory: ${WORK_BASE}"
echo "Output directory: ${OUTPUT_BASE}"
echo "=========================================="
echo ""

JOBFILE="\${LOG_DIR}/submitted_jobs_\$(date +%Y%m%d_%H%M%S).txt"
echo "Sample,Download,Compress,Trim,Align,Coverage" > "\$JOBFILE"

while read SRR; do
    # Skip empty lines and comments
    [[ -z "\$SRR" || "\$SRR" =~ ^# ]] && continue
    
    echo "Submitting pipeline for: \${SRR}"
    
    JOB1=\$(sbatch --parsable --export=SRR=\${SRR} --job-name=\${SRR}_dl \${SCRIPT_DIR}/01-download-single.sbatch)
    JOB2=\$(sbatch --parsable --dependency=afterok:\${JOB1} --export=SRR=\${SRR} --job-name=\${SRR}_cmp \${SCRIPT_DIR}/02-compress-single.sbatch)
    JOB3=\$(sbatch --parsable --dependency=afterok:\${JOB2} --export=SRR=\${SRR} --job-name=\${SRR}_trm \${SCRIPT_DIR}/03-fastp-single.sbatch)
    JOB4=\$(sbatch --parsable --dependency=afterok:\${JOB3} --export=SRR=\${SRR} --job-name=\${SRR}_aln \${SCRIPT_DIR}/04-align-single.sbatch)
    JOB5=\$(sbatch --parsable --dependency=afterok:\${JOB4} --export=SRR=\${SRR} --job-name=\${SRR}_cvg \${SCRIPT_DIR}/05-coverage-single.sbatch)
    
    echo "  Jobs: \${JOB1} -> \${JOB2} -> \${JOB3} -> \${JOB4} -> \${JOB5}"
    echo "\${SRR},\${JOB1},\${JOB2},\${JOB3},\${JOB4},\${JOB5}" >> "\$JOBFILE"
    
done < "\$SRR_LIST"

echo ""
echo "=========================================="
echo "All pipelines submitted!"
echo "Job tracking file: \$JOBFILE"
echo ""
echo "Monitor with: squeue -u \$USER"
echo "Or: watch -n 10 'squeue -u \$USER'"
echo "=========================================="
EOF

chmod +x ${SCRIPT_DIR}/launch_all.sh

# Copy SRR list to working directory
cp "$SRR_LIST" "${WORK_BASE}/SRR-ids.txt"

# Create a monitoring script
cat > ${SCRIPT_DIR}/check_status.sh << EOF
#!/bin/bash
# check_status.sh - Check pipeline status for all samples

OUTPUT_BASE="${OUTPUT_BASE}"
WORK_BASE="${WORK_BASE}"

echo "=========================================="
echo "Pipeline Status Check"
echo "=========================================="
echo ""

if [ ! -f "\${WORK_BASE}/SRR-ids.txt" ]; then
    echo "Error: SRR-ids.txt not found"
    exit 1
fi

printf "%-15s %-10s %-10s %-10s %-10s %-10s\n" "Sample" "Download" "Compress" "Trim" "Align" "Coverage"
echo "--------------------------------------------------------------------------------"

while read SRR; do
    [[ -z "\$SRR" || "\$SRR" =~ ^# ]] && continue
    
    # Check for output files
    DL=\$([ -f "\${OUTPUT_BASE}/fastq/\${SRR}_1.fastq.gz" ] && echo "✓" || echo "✗")
    TR=\$([ -f "\${OUTPUT_BASE}/fastq_trimmed/\${SRR}_1.trimmed.fastq.gz" ] && echo "✓" || echo "✗")
    AL=\$([ -f "\${OUTPUT_BASE}/bams/\${SRR}_Aligned.sortedByCoord.out.bam" ] && echo "✓" || echo "✗")
    CV=\$([ -f "\${OUTPUT_BASE}/results/\${SRR}_coverage_summary.txt" ] && echo "✓" || echo "✗")
    
    printf "%-15s %-10s %-10s %-10s %-10s %-10s\n" "\$SRR" "\$DL" "\$DL" "\$TR" "\$AL" "\$CV"
done < "\${WORK_BASE}/SRR-ids.txt"

echo ""
echo "Running jobs:"
squeue -u \$USER -o "%.18i %.9P %.30j %.8T %.10M %.6D"
EOF

chmod +x ${SCRIPT_DIR}/check_status.sh

# Create summary aggregator
cat > ${SCRIPT_DIR}/aggregate_results.sh << EOF
#!/bin/bash
# aggregate_results.sh - Combine all coverage summaries

RESULTS_DIR="${OUTPUT_BASE}/results"
OUTPUT="\${RESULTS_DIR}/ALL_samples_coverage_summary.txt"

echo "Sample,Total_Loci,Loci_Cov_gt_0,Loci_Cov_gte_10,Mean_Coverage,Median_Coverage,Max_Coverage" > "\$OUTPUT"

for SUMMARY in \${RESULTS_DIR}/*_coverage_summary.txt; do
    [ ! -f "\$SUMMARY" ] && continue
    
    SRR=\$(basename "\$SUMMARY" _coverage_summary.txt)
    TOTAL=\$(grep "Total snaR-A loci:" "\$SUMMARY" | awk '{print \$NF}')
    COV0=\$(grep "Loci with coverage >0:" "\$SUMMARY" | awk '{print \$NF}')
    COV10=\$(grep "Loci with coverage >=10:" "\$SUMMARY" | awk '{print \$NF}')
    MEAN=\$(grep "Mean coverage:" "\$SUMMARY" | awk '{print \$NF}')
    MEDIAN=\$(grep "Median coverage:" "\$SUMMARY" | awk '{print \$NF}')
    MAX=\$(grep "Max coverage:" "\$SUMMARY" | awk '{print \$NF}')
    
    echo "\${SRR},\${TOTAL},\${COV0},\${COV10},\${MEAN},\${MEDIAN},\${MAX}" >> "\$OUTPUT"
done

echo "Aggregate results saved to: \$OUTPUT"
column -t -s',' "\$OUTPUT"
EOF

chmod +x ${SCRIPT_DIR}/aggregate_results.sh

echo ""
echo "=========================================="
echo "Setup complete!"
echo "=========================================="
echo ""
echo "To launch pipeline for all samples:"
echo "  cd ${WORK_BASE}"
echo "  ./scripts/launch_all.sh SRR-ids.txt"
echo ""
echo "To check status:"
echo "  ./scripts/check_status.sh"
echo ""
echo "To aggregate results:"
echo "  ./scripts/aggregate_results.sh"
echo ""
