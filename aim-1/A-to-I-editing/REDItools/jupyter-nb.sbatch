#!/bin/bash

#SBATCH --job-name=jupyter
#SBATCH --output=jupyter_notebook_%j.log
#SBATCH --ntasks=1
#SBATCH --mem=16gb
#SBATCH --time=04:00:00

date;hostname;pwd
module load jupyter/6.5.2
launch_jupyter_notebook
