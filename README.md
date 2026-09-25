# proj-xie-snaR

A-to-I RNA editing of snaR-A in public RNA-seq data, for the Xie lab
(Mingyi Xie, PI; Wenyan Han). BCB-SR bioinformatics support, Heather Kates.

**Status: paused since January 2026.** Wenyan and Ming decided on 2026-01-06
to pause the analysis until wet-lab data from the relevant human tissues are
available, because suitable public datasets are too limited. This repo records
what was run so the work can be restarted.

## Question

Is snaR-A edited by ADAR, as Alu elements are? The planned test compares the
A-to-G mismatch rate (the RNA-seq readout of A-to-I editing) at snaR-A loci
between ADAR knockout or knockdown and wild-type samples, with Alu as the
positive control. The original plan is in
[`docs/project-notes.md`](docs/project-notes.md).

## Where things are

| What | Location |
|---|---|
| Code (this repo) | `/blue/mingyi.xie/hkates/A001-snaR` |
| FASTQs, trimmed reads, BAMs, fastp reports | `/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/<GSE>/` |
| STAR index (UCSC hg38) | `/orange/mingyi.xie/hkates/A001-snaR/aim-1/A-to-I-editing/references/STARIndex_ucsc_hg38` |
| RNAEditingIndexer container | `/blue/cancercenter-dept/tools/containers/rnaeditingindexer.sif` |

SLURM account and QOS used throughout: `cancercenter-dept`.

Only code, region files and small result tables are in git. BAMs, FASTQs,
pileups and containers are excluded by `.gitignore`.

## Layout

```
aim-1/A-to-I-editing/
  setup-GEO-pipeline.bash   generates a per-sample SLURM pipeline for any GSE
  AnnotationAndRegions/     snaR-A loci (hg38) as BED / GFF3; RefSeq chr19 BED
  bash/                     first-pass scripts, developed on GSE99249
  GSE99249/ GSE56152/ GSE155964/ GSE271019/
    scripts/                per-dataset download, trim, align, coverage check
  REDItools/                REDItools setup (notebook); not run to results
  lodei/                    LoDEI setup; run on GSE155964 did not finish
aim-2/                      not started
```

## Pipeline

`setup-GEO-pipeline.bash <GSE_ID> <SRR_list.txt>` writes these scripts into
`<GSE_ID>/scripts/`, and `launch_all.sh` submits them per sample as a chain of
dependent SLURM jobs:

1. `01-download-single.sbatch` — `fasterq-dump --split-files`. In: SRR ID. Out: paired FASTQs.
2. `02-compress-single.sbatch` — `pigz`. Out: `.fastq.gz`.
3. `03-fastp-single.sbatch` — `fastp --detect_adapter_for_pe --length_required 20`. Out: trimmed FASTQs, HTML/JSON reports.
4. `04-align-single.sbatch` — STAR against UCSC hg38, unspliced (`--alignIntronMax 1`), up to 20 multimapping locations and 7% mismatches per read so that edited, repetitive reads still align. Out: coordinate-sorted, indexed BAM.
5. `05-coverage-single.sbatch` — `bedtools coverage` over the snaR-A BED. Out: per-locus coverage and a summary.

`check_status.sh` reports which steps have finished per sample, and
`aggregate_results.sh` combines the coverage summaries.

Editing is then measured with RNAEditingIndexer
(`bash/06-run-RNAEditingIndexer-snaR-A.bash`, `bash/use-this.bash`). In: BAMs,
UCSC hg38 FASTA, a region BED (snaR-A or Alu). Out: `EditingIndex.csv`, one row
per sample, with the A-to-G editing index (A-to-G mismatches as a percent of
all adenosine coverage in the regions) and the other eleven mismatch types as
background.

Known issue: the summary lines in `05-coverage-single.sbatch` (mean, median,
max) come out empty because of `awk` quoting inside the generated heredoc. The
per-locus `*_snaR-A_coverage.txt` files are correct.

## Datasets tried

| GEO | Description | Status |
|---|---|---|
| GSE99249 | ADAR1 editome during IFN response, human cell lines | 6 BAMs aligned. RNAEditingIndexer read 0 records in the snaR-A region on the test sample |
| GSE56152 | WT and ADAR1-knockdown H9 cells: polyA RNA-seq and small RNA-seq | 4 samples aligned (`data/metadata.csv`); small RNA library also aligned with short-read STAR settings (`03b-align-sRNA.sbatch`) |
| GSE155964 | Immunogenic dsRNAs in human cell lines | 4 samples run through RNAEditingIndexer for snaR-A and Alu — results below |
| GSE271019 | Mouse brain RNA modifications / inosine | 1 sample aligned; mouse, so snaR-A (primate-specific) coordinates do not apply directly |

## Results (GSE155964)

`GSE155964/*-outs/output/EditingIndex.csv`:

| Sample | Alu A-to-G index (%) | Alu A-to-G mismatches | snaR-A A-to-G index (%) | snaR-A A-to-G mismatches |
|---|---|---|---|---|
| SRR12419620 | 0.29 | 105,860 | 0.00 | 4 |
| SRR12419621 | 0.37 | 172,935 | 0.08 | 2 |
| SRR12419622 | 0.66 | 411,925 | 0.00 | 11 |
| SRR12419623 | 0.93 | 365,876 | 0.16 | 3 |

The Alu control (chr1 Alu elements) shows editing in every sample. snaR-A has
2–11 A-to-G mismatches per sample, too few reads to estimate an editing rate or
compare groups. `snaR-A-outs-with-SNP` repeats two samples with dbSNP 150
common A/G and T/C SNPs masked; the result does not change.

This matches what was found across the four datasets: snaR-A is a ~117 nt
Pol III transcript, and polyA-selected or size-selected libraries do not
capture it at enough depth. Few GEO datasets have an ADAR knockout group and
use total RNA without size selection.

## Restarting

- A dataset needs total (rRNA-depleted, not polyA) RNA-seq with enough reads
  at snaR-A loci — check this with `05-check-snaR-A-cvg.bash` before running
  the editing analysis.
- `AnnotationAndRegions/snp150Common_AG_TC.bed.gz` (dbSNP 150 common A/G and
  T/C SNPs, 55 MB) is excluded from git for size and remains on `/blue`.
  `bash/05-get-ucsc-anno.bash` downloads the current UCSC common SNP table
  (dbSNP 151) if it needs rebuilding.
- The original plan used BASAL (`docs/project-notes.md`); that remains an
  option if per-site editing rates are needed rather than a regional index.
