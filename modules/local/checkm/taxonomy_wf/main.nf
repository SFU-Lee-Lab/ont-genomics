process CHECKM_TAXONOMYWF {
    tag "${meta.id}"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/checkm-genome:1.2.5--pyhdfd78af_0'
        : 'quay.io/biocontainers/checkm-genome:1.2.5--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(fasta, stageAs: "input_bins/*"), val(species_id)
    val fasta_ext

    output:
    tuple val(meta), path("${prefix}"), emit: checkm_output
    tuple val(meta), path("${prefix}.tsv"), emit: checkm_tsv
    tuple val("${task.process}"), val('checkm'), eval("checkm 2>&1 | grep '...:::' | sed 's/.*CheckM v//;s/ .*//'"), emit: versions_checkm, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    checkm \\
        taxonomy_wf \\
        species "${species_id}" \\
        -t ${task.cpus} \\
        -f ${prefix}.tsv \\
        --tab_table \\
        -x ${fasta_ext} \\
        ${args} \\
        input_bins/ \\
        ${prefix}
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir ${prefix}/
    touch ${prefix}/lineage.ms ${prefix}.tsv
    """
}
