# Run over samples
SAMPLES = ["KW10"]

# Define the paths for input and output directories
INPUT_DIR = "Raw_Data"
OUTPUT_DIR = "Results"
REFERENCE_DIR = "Reference_Genome"

# Final output
rule all:
    input:
        expand("Results/analysis/{sample}_Multiome/outs/summary.csv", sample=SAMPLES)


# Rule for filtering annotation reference genome
rule filter_annotation:
    input:
        annotation = "Reference_Genome/Peromyscus_maniculatus_bairdii.HU_Pman_2.1.110.gtf"
    output:
        filtered_annotation = "Reference_Genome/Peromyscus_maniculatus_bairdii.HU_Pman_2.1.110.gtf_filtered.gtf"
    log:
        "Results/logs/filter_annotation.log"
    shell:
        """
        cellranger-arc mkgtf Reference_Genome/Peromyscus_maniculatus_bairdii.HU_Pman_2.1.110.gtf Reference_Genome/Peromyscus_maniculatus_bairdii.HU_Pman_2.1.110.gtf_filtered.gtf \
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
            --attribute=gene_biotype:TR_C_gene
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
        summary = "Results/analysis/{sample}_Multiome/outs/summary.csv"
    log:
        "Results/logs/cellranger_arc_count_{sample}.log"
    wildcard_constraints:
        sample = "|".join(SAMPLES)
    shell:
        """
        cellranger-arc count \
            --id={wildcards.sample}_Multiome \
            --reference={input.reference} \
            --libraries={input.libraries}
        """