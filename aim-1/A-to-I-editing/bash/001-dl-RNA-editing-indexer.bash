#!/bin/bash
#SBATCH --job-name=build-indexer
#SBATCH --output=logs/build-rna-editing-indexer.out
#SBATCH --error=logs/build-rna-editing-indexer.err
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept

cd /blue/cancercenter-dept/tools
# git clone https://github.com/a2iEditing/RNAEditingIndexer.git
cd RNAEditingIndexer

# Load dependencies
ml samtools/1.20
ml bedtools
ml java

# Check versions
samtools --version  # Should be ≥1.8
bedtools --version  # Should be ≥2.26

# Configure with install path
. ./configure.sh --install-dir /blue/cancercenter-dept/tools/RNAEditingIndexer

make
