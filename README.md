Snakemake Pipeline for 10X Genomics Multiome Data
==================================================
The goal of this Snakemake pipeline is to streamline the processing of 10X Genomics Single Cell Multiome ATAC + Gene Expression (GEX) sequencing data. Multiome data contains information pertaining to both gene expression and chromatin accessibility, allowing for linkage between the two on a single cell basis. 

This pipeline will combine multiple steps of the typical 10X Multiome workflow which uses [Cell Ranger ARC](https://support.10xgenomics.com/single-cell-multiome-atac-gex/software/pipelines/latest/what-is-cell-ranger-arc). Cell Ranger ARC is a set of analysis pipeline that identifies open chromatin regions and simultaneously counts transcripts and peak accessbility in a single cell.

This Snakemake pipeline was specifically written to analyze single cell data from deer mouse (_Peromyscus maniculatus_) placentas, necessitating the generation of a custom reference transcriptome.


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
        
      - For example:

```fastqs,sample,library_type
/home/projects/Raw_Data,SAMPLE-ATAC_1,Chromatin Accessibility
/home/projects/Raw_Data,SAMPLE-ATAC_2,Chromatin Accessibility
/home/projects/Raw_Data,SAMPLE-ATAC_3,Chromatin Accessibility
/home/projects/Raw_Data,SAMPLE-ATAC_4,Chromatin Accessibility
/home/projects/Raw_Data,SAMPLE-GEX,Gene Expression
```
        
4. Ensure FASTA and GTF file are in **_Reference_Genome_** directory
   - Edit FASTA and GTF file names in filter_annotation & config rules


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
#SBATCH --ntasks=24
#SBATCH --time=unlimited
#SBATCH --output=/home/projects/Results/logs/log_snakemake_%J.txt

snakemake --conda-frontend conda --cores 4 all
```

Step 4: Check Output
--------------------
The output of Cell Ranger ARC should be a folder with the "SAMPLE_Multiome" name previously specified. 

The subfolder named `outs` will contain the main pipeline output files:

|File Name|Description|
|:-------|:---------|
|web_summary.html|Run summary metrics and charts in HTML format|
|summary.csv|Run summary metrics in CSV format|
|raw_feature_bc_matrix.h5|Raw feature barcode matrix stored as a CSC sparse matrix in hdf5 format. The rows consist of all the gene and peak features concatenated together and the columns consist of all observed barcodes with non-zero signal for either ATAC or gene expression.|
|raw_feature_bc_matrix|	Raw feature barcode matrix stored as a CSC sparse matrix in MEX format. The rows consist of all the gene and peak features concatenated together and the columns consist of all observed barcodes with non-zero signal for either ATAC or gene expression|
|per_barcode_metrics.csv|ATAC and GEX read count summaries generated for every barcode observed in the experiment. For more details see Per-barcode metrics|
|gex_possorted_bam.bam|GEX reads aligned to the genome and transcriptome annotated with barcode information in BAM format|
|gex_possorted_bam.bam.bai|Index for gex_possorted_bam.bam|
|gex_molecule_info.h5|Count and barcode information for every GEX molecule observed in the experiment in hdf5 format|
|filtered_feature_bc_matrix.h5|Filtered feature barcode matrix stored as a CSC sparse matrix in hdf5 format. The rows consist of all the gene and peak features concatenated together (identical to raw feature barcode matrix) and the columns are restricted to those barcodes that are identified as cells|
|filtered_feature_bc_matrix|Filtered feature barcode matrix stored as a CSC sparse matrix in MEX format. The rows consist of all the gene and peak features concatenated together (identical to raw feature barcode matrix) and the columns are restricted to those barcodes that are identified as cells|
|cloupe.cloupe|Loupe Browser visualization file with all the analysis outputs|
|atac_possorted_bam.bam|ATAC reads aligned to the genome annotated with barcode information in BAM format|
|atac_possorted_bam.bam.bai|Index for atac_possorted_bam.bam|
|atac_peaks.bed|Locations of open-chromatin regions identified in this sample. These regions are referred to as "peaks"|
|atac_peak_annotation.tsv|Annotations of peaks based on genomic proximity alone. Note that these are not functional annotations and they do not make use of linkage with GEX data|
|atac_fragments.tsv.gz|	Count and barcode information for every ATAC fragment observed in the experiment in TSV format|
|atac_fragments.tsv.gz.tbi|Index for atac_fragments.tsv.gz|
|atac_cut_sites.bigwig|Genome track of observed transposition sites in the experiment smoothed at a resolution of 400 bases in BIGWIG format|
|analysis|	Various secondary analyses that utilize the ATAC data, the GEX data, and their linkage: dimensionality reduction and clustering results for the ATAC and GEX data, differential expression, and differential accessibility for all clustering results above and linkage between ATAC and GEX data|


Step 5: Next Steps
------------------

The typical next steps include:
- View web_summary.html
- Import raw_feature_bc_matrix.h5 into RStudio for data analysis and visualization using [Seurat: R Toolkit for single cell genomics](https://satijalab.org/seurat/).







