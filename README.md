Snakemake Pipeline for 10X Genomics Multiome Data
==================================================
The goal of this Snakemake pipeline is to streamline the processing of 10X Genomics Single Cell Multiome ATAC + Gene Expression (GEX) sequencing data. Multiome data contains information pertaining to both gene expression and chromatin accessibility, allowing for linkage between the two on a single cell basis. 

This pipeline will combine multiple steps of the typical 10X Multiome workflow which uses [Cell Ranger ARC](https://support.10xgenomics.com/single-cell-multiome-atac-gex/software/pipelines/latest/what-is-cell-ranger-arc). Cell Ranger ARC is a set of analysis pipeline that identifies open chromatin regions and simultaneously counts transcripts and peak accessbility in a single cell.

This Snakemake pipeline was specifically written to analyze single cell data from deer mouse placentas, necessitating the generation of a custom reference transcriptome.

Step 1: Set up the workflow
------------------------

1. Firstly, download the latest version of [10X Cell Ranger ARC](https://support.10xgenomics.com/single-cell-multiome-atac-gex/software/downloads/latest) into your working directory.

      - Unpack using `tar -xzvf cellranger-arc-x.y.z.tar.gz`

2. Prepend the Cell Ranger ARC directory to your $PATH. `export PATH=/opt/cellranger-arc-x.y.z:$PATH`. This will allow you to invoke the cellranger-arc command.

      - Enter `which cellranger-arc` to confirm whether cellranger-arc was successfullly added to the $PATH.  
        > Expected outcome `/home/projects/cellranger-arc-x.y.z/cellranger-arc`
   
      - For your convenience, you may want to add the $PATH command to your `.bashrc` file.  

Step 2: Modify Snakefile and components to accurately reflect file paths
-------------------------------------------------------------------
1. Modify `SAMPLES` to reflect sample names.
   
2. Ensure fastq files are in **_Raw_Data_** directory
      - Paired gene expression fastq files (SAMPLE-GEX_S1_L001_R1_001.fastq.gz)
      - Paired ATAC fastq files (SAMPLE-ATAC_1_S13_L001_I1_001.fastq.gz)
        
3. Modify _libraries.csv_ in **_Raw_Data_** directory
      - Fastqs: A fully qualified path to the directory containing the demultiplexed FASTQ files.
      - Sample: Assigned sample name.
      - Library_type: This field is _case-sensitive_ and must exactly match `Chromatin Accessibility` for a Multiome ATAC library and `Gene Expression` for a Multiome GEX library.  

   
```fastqs,sample,library_type
/home/projects/Raw_Data,SAMPLE-ATAC_1,Chromatin Accessibility
/home/projects/Raw_Data,SAMPLE-ATAC_2,Chromatin Accessibility
/home/projects/Raw_Data,SAMPLE-ATAC_3,Chromatin Accessibility
/home/projects/Raw_Data,SAMPLE-ATAC_4,Chromatin Accessibility
/home/projects/Raw_Data,SAMPLE-GEX,Gene Expression
```
        
4. Ensure FASTA and GTF file are in **_Reference_Genome_** directory

Step 3: Submit Snakemake job
----------------------------
Test snakemake configuration by performing a dry-run via
`snakemake --conda-frontend conda -np all`

Execute the workflow locally using 
`snakemake --conda-frontend conda --core 4 all`

Alternatively, edit [submit_snakemake.sh](https://github.com/mjhemmerlein/snakemake-single-cell/blob/main/submit_snakemake.sh) to submit to SLURM.
```
#!/usr/bin/env bash

#SBATCH --job-name=snakemake
#SBATCH --nodes=1
#SBATCH --ntasks=24 # modify this number to reflect how many cores you want to use (up to 24)
#SBATCH --time=unlimited   # modify this to reflect how long to let the job go.
#SBATCH --output=/home/mjhemm/projects/snakemake-single-cell/Results/logs/log_snakemake_%J.txt

snakemake --conda-frontend conda --cores 4 all
```










