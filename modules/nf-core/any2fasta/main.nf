process ANY2FASTA {
    tag "${meta.id}"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/any2fasta:0.8.1--hdfd78af_0'
        : 'quay.io/biocontainers/any2fasta:0.8.1--hdfd78af_0'}"

    input:
    tuple val(meta), path(sequence)

    output:
    tuple val(meta), path("*.fasta"), emit: fasta
    tuple val("${task.process}"), val('any2fasta'), emit: versions_any2fasta

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    any2fasta \\
        ${args} \\
        ${sequence} \\
        > ${prefix}.fasta
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo ${args}
    touch ${prefix}.fasta
    """
}
