Snakemake Pipeline for 10X Genomics Multiome Data
==================================================
The goal of this Snakemake pipeline is to streamline the processing of 10X Genomics Single Cell Multiome ATAC + Gene Expression (GEX) sequencing data. Multiome data contains information pertaining to both gene expression and chromatin accessibility, allowing for linkage between the two on a single cell basis. 

This pipeline will combine multiple steps of the typical 10X Multiome workflow which uses [Cell Ranger ARC](https://support.10xgenomics.com/single-cell-multiome-atac-gex/software/pipelines/latest/what-is-cell-ranger-arc). Cell Ranger ARC is a set of analysis pipeline that identifies open chromatin regions and simultaneously counts transcripts and peak accessbility in a single cell.

This Snakemake pipeline was specifically written to analyze single cell data from deer mouse placentas, necessitating the generation of a custom reference transcriptome.

Setting up the workflow
------------------------

1. Firstly, download the latest version of [10X Cell Ranger ARC](https://support.10xgenomics.com/single-cell-multiome-atac-gex/software/downloads/latest) into your working directory.

      - Unpack using `tar -xzvf cellranger-arc-x.y.z.tar.gz`

2. Prepend the Cell Ranger ARC directory to your $PATH. `export PATH=/opt/cellranger-arc-x.y.z:$PATH`. This will allow you to invoke the cellranger-arc command.

      - Enter `which cellranger-arc` to confirm whether cellranger-arc was successfullly added to the $PATH.  
        > Expected outcome `/home/projects/cellranger-arc-x.y.z/cellranger-arc`
   
      - For your convenience, you may want to add the $PATH command to your `.bashrc` file.  

Modifying Snakefile to accurately reflect file paths
----------------------------------------------------
1. Modify `SAMPLES` to reflect sample names.
   
2. Ensure follow fastq files are in **_Raw_Data_** directory
      - Paired gene expression fastq files (SAMPLE-GEX_S1_L001_R1_001.fastq.gz)
      - Paired ATAC fastq files (SAMPLE-ATAC_1_S13_L001_I1_001.fastq.gz)
        
3. Modify libraries.csv in **_Raw_Data_** directory
      - Fastqs: A fully qualified path to the directory containing the demultiplexed FASTQ files.
      - Sample: Assigned sample name
      - Library_type: This field is _case-sensitive_ and must exactly match `Chromatin Accessibility` for a Multiome ATAC library and `Gene Expression` for a Multiome GEX library. 
   
|fastqs                 | sample    | library_type          |
|:---------------------:|:---------:|:---------------------:|
|/home/projects/Raw_Data|SAMP-ATAC_1|Chromatin Accessibility|
|/home/projects/Raw_Data|SAMP-GEX   |Gene Expression        |












