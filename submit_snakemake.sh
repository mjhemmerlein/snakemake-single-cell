#!/usr/bin/env bash

#SBATCH --job-name=snakemake
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --time=unlimited
#SBATCH --output=/home/mjhemm/projects/snakemake-single-cell/Results/logs/log_snakemake_%J.txt

snakemake --conda-frontend conda --cores 4 all