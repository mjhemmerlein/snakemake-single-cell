#!/usr/bin/env bash

#SBATCH --job-name=snakemake
#SBATCH --nodes=1
#SBATCH --ntasks=24 # modify this number to reflect how many cores you want to use (up to 24)
#SBATCH --time=unlimited   # modify this to reflect how long to let the job go.
#SBATCH --output=/home/mjhemm/projects/snakemake-single-cell/Results/logs/snakemake_%J.txt

snakemake --conda-frontend conda all