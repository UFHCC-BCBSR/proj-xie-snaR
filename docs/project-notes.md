# Project notes (2025-12-04)

Aim 1, Organ expression and ADAR-editing profiling.
Part 2, A-to-I editing: systematically identify and quantify A-to-I RNA editing
sites and ratios within snaR transcripts, using wild-type (WT) and ADAR
knockout (KO) whole-transcriptome sequencing datasets.

## Input data

RNA-seq from ADAR KO and WT cell lines (GEO: GSE99249). Reference: human
genome GRCh38. snaR-A and Alu genomic coordinates used to extract regions as
needed.

## Research question

Is snaR-A edited by ADAR enzymes, as Alu elements are? A significant drop in
A-to-I editing frequency in snaR-A in ADAR KO compared to WT would indicate
that snaR-A editing is ADAR-dependent.

## Method as planned

Trim adapters (Trimmomatic), align with BASAL using A-to-G conversion
detection (`-M A:G`), allowing multi-mapping (`-w 100`), 6% mismatches
(`-v 0.06`), 12 nt seeds (`-s 12`) and Q20 quality trimming (`-q 20`).
Calculate per-adenosine editing frequency with BASALkit `avgmod -M A:G`, and
compare WT to ADAR KO with BASALkit `fdr`.

Conner Traugot (connertraugot@ufl.edu) has used BASAL and offered example
scripts; BASALkit functions are poorly documented.

## Expected output

- Per-sample snaR-A editing frequencies, WT versus KO, FDR < 0.05
- Summary tables and plots of mean editing rate by group
- Aligned BAMs per sample; merged BAMs; raw `avgmod` output
- Filtered high-confidence sites: depth >= 10, editing > 10% in WT,
  reproducible across replicates

## What was done instead

The work used STAR alignment followed by RNAEditingIndexer, with REDItools
and LoDEI tested as alternatives. BASAL was not run. See the README.
