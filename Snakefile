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
    shell:
        """
        # Download and extract cellranger-arc
        wget -O cellranger-arc-2.0.2.tar.gz "https://cf.10xgenomics.com/releases/cell-arc/cellranger-arc-2.0.2.tar.gz?Expires=1705486220&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jZi4xMHhnZW5vbWljcy5jb20vcmVsZWFzZXMvY2VsbC1hcmMvY2VsbHJhbmdlci1hcmMtMi4wLjIudGFyLmd6IiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzA1NDg2MjIwfX19XX0_&Signature=kjD6jPqvREd~rcxX0AiBfJQlc9QDtJjWDfQm1TMLOxjgGVH3uSk7uymY4iQXOU-T3jMu5KutNsp4vgR7Bp7cKg03heyMVRf05vm4c5dJTqyrzaee7cc0MafwtbJLMK5wpwXb0jAVTI9VVbJSKf1RF8aFqpxbnSi8iaHrvwT45vjedQXHj5UyuxEe-9IDP45G4lHgcP9Rac~E9TLAuceuQYRpN0ye9kL4i1CbEU~Hxg~BfDWdPUeC~iY6AEfZYf8qC1qSmpiNYgNkvL0r4YPCxJo9oq-9asofFoNrfZLzLGeJ22Yfq9FobCZ9V7X79tnKSNO-UkPV1ejRm4tCfcasTg__&Key-Pair-Id=APKAI7S6A5RYOXBWRPDA"
        tar -xzf cellranger-arc-2.0.2.tar.gz

        # Add cellranger-arc to PATH
        echo 'export PATH=$PWD/cellranger-arc-2.0.2:$PATH' >> $HOME/.bashrc
        source $HOME/.bashrc

        # Verify installation
        cellranger-arc --version

        # Create a dummy file to mark the rule as completed
        touch cellranger-arc.installed
        """

# Rule for filtering annotation reference genome
rule filter_annotation:
    input:
        annotation = "Reference_Genome/Peromyscus_maniculatus_bairdii.HU_Pman_2.1.110.gtf"
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
        reference = "{REFERENCE_DIR}/Pman_genome",
        libraries = "{INPUT_DIR}/libraries.csv"
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