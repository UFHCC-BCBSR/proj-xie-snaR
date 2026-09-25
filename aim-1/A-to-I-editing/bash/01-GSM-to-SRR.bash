#!/bin/bash

# Create header
echo "GSM,SRR" > gsm_srr_mapping.csv

# Loop through each GSM and extract just GSM and SRR columns
while read gsm; do
    pysradb gsm-to-srr --detailed $gsm | tail -n +2 | awk -v gsm="$gsm" '{print gsm","$2}'
done < gsm_list.txt >> gsm_srr_mapping.csv

cut -d "," -f 2 gsm_srr_mapping.csv | awk 'NR > 1 { print }' > srr-list.txt



