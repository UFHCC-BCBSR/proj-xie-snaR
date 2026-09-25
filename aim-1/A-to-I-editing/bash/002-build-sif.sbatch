#!/bin/bash
#SBATCH --job-name=pull_aei
#SBATCH --output=logs/pull_aei.out
#SBATCH --error=logs/pull_aei.err
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=03:00:00
#SBATCH --account=cancercenter-dept
#SBATCH --qos=cancercenter-dept-b

ml singularity

mkdir -p /blue/cancercenter-dept/tools/containers

echo "Pulling Docker image levanonlab/rna-editing-index:1.0"
date

singularity pull \
    /blue/cancercenter-dept/tools/containers/rnaeditingindexer.sif \
    docker://levanonlab/rna-editing-index:1.0

echo "Pull complete!"
ls -lh /blue/cancercenter-dept/tools/containers/rnaeditingindexer.sif
date
