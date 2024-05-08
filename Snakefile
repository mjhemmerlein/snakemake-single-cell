# Run over samples
SAMPLES = ["KW10"]

# Define the paths for input and output directories
INPUT_DIR = "Raw_Data"
OUTPUT_DIR = "Results"
REFERENCE_DIR = "Reference_Genome"

# Rule for installing cellranger-arc
rule install_cellranger_arc:
    output:
        touch("cellranger-arc.installed")
    params:
        cellranger_arc_path = "/home/mjhemm/projects/CellRanger/01_input/cellranger-arc-2.0.2"
    shell:
        """
        # Add cellranger-arc to PATH
        echo 'export PATH={params.cellranger_arc_path}:$PATH' >> $HOME/.bashrc
        source $HOME/.bashrc

        # Verify installation
        cellranger-arc --version

        # Create a dummy file to mark the rule as completed
        touch cellranger-arc.installed
        """

# Rule for filtering annotation reference genome
rule filter_annotation:
    input:
        annotation = "Reference_Genome/Peromyscus_maniculatus_bairdii.HU_Pman_2.1.110.gtf",
        install_cellranger_arc = "cellranger-arc.installed"
    output:
        filtered_annotation = "Reference_Genome/{input.annotation.name}_filtered.gtf"
    log:
        "Results/logs/filter_annotation.log"
    shell:
        """
        cellranger-arc mkgtf \
            --attribute=gene_biotype:protein_coding \
            --attribute=gene_biotype:lncRNA \
            --attribute=gene_biotype:antisense \
            --attribute=gene_biotype:IG_LV_gene \
            --attribute=gene_biotype:IG_V_gene \
            --attribute=gene_biotype:IG_V_pseudogene \
            --attribute=gene_biotype:IG_D_gene \
            --attribute=gene_biotype:IG_J_gene \
            --attribute=gene_biotype:IG_J_pseudogene \
            --attribute=gene_biotype:IG_C_gene \
            --attribute=gene_biotype:IG_C_pseudogene \
            --attribute=gene_biotype:TR_V_gene \
            --attribute=gene_biotype:TR_V_pseudogene \
            --attribute=gene_biotype:TR_D_gene \
            --attribute=gene_biotype:TR_J_gene \
            --attribute=gene_biotype:TR_J_pseudogene \
            --attribute=gene_biotype:TR_C_gene \
            {input.annotation} > {output.filtered_annotation}
        """

# Rule for creating config file
rule config:
    input:
        fasta = "Reference_Genome/Peromyscus_maniculatus_bairdii.HU_Pman_2.1.dna.toplevel.fa",
        filtered_annotation = "Reference_Genome/{input.annotation.name}_filtered.gtf"
    output:
        config = "Pman_genome.config"
    log:
        "Results/logs/config.log"
    shell:
        """
        cat > {output.config} << EOF
        organism: "Peromyscus_maniculatus"
        genome: ["Pman_genome"]
        input_fasta: ["Peromyscus_maniculatus_bairdii.HU_Pman_2.1.dna.toplevel.fa"]
        input_gtf: ["{input.filtered_annotation}"]
        EOF
        """

# Rule for creating the reference genome
rule mkref:
    input:
        config = "Pman_genome.config"
    output:
        directory("Reference_Genome/Pman_genome")
    log:
        "Results/logs/mkref.log"
    shell:
        "cellranger-arc mkref \
            --config={input.config}"


# Rule for cell ranger arc count
rule cellranger_arc_count:
    input:
        reference = "Reference_Genome/Pman_genome",
        libraries = "Raw_Data/libraries.csv"
    output:
        summary = "Results/analysis/{wildcards.sample}_Multiome/outs/summary.csv"
    log:
        "Results/logs/cellranger_arc_count_{wildcards.sample}.log"
    shell:
        """
        cellranger-arc count \
            --id={wildcards.sample}_Multiome \
            --reference={input.reference} \
            --libraries={input.libraries}
        """