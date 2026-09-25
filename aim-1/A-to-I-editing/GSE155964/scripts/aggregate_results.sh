#!/bin/bash
# aggregate_results.sh - Combine all coverage summaries

RESULTS_DIR="/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/GSE155964/results"
OUTPUT="${RESULTS_DIR}/ALL_samples_coverage_summary.txt"

echo "Sample,Total_Loci,Loci_Cov_gt_0,Loci_Cov_gte_10,Mean_Coverage,Median_Coverage,Max_Coverage" > "$OUTPUT"

for SUMMARY in ${RESULTS_DIR}/*_coverage_summary.txt; do
    [ ! -f "$SUMMARY" ] && continue
    
    SRR=$(basename "$SUMMARY" _coverage_summary.txt)
    TOTAL=$(grep "Total snaR-A loci:" "$SUMMARY" | awk '{print $NF}')
    COV0=$(grep "Loci with coverage >0:" "$SUMMARY" | awk '{print $NF}')
    COV10=$(grep "Loci with coverage >=10:" "$SUMMARY" | awk '{print $NF}')
    MEAN=$(grep "Mean coverage:" "$SUMMARY" | awk '{print $NF}')
    MEDIAN=$(grep "Median coverage:" "$SUMMARY" | awk '{print $NF}')
    MAX=$(grep "Max coverage:" "$SUMMARY" | awk '{print $NF}')
    
    echo "${SRR},${TOTAL},${COV0},${COV10},${MEAN},${MEDIAN},${MAX}" >> "$OUTPUT"
done

echo "Aggregate results saved to: $OUTPUT"
column -t -s',' "$OUTPUT"
