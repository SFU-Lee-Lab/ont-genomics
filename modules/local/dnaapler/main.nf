process DNAAPLER {
    tag "${meta.id}"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/dnaapler:1.4.0--pyhdfd78af_0':
        'quay.io/repository/biocontainers/dnaapler:1.4.0--pyhdfd78af_0' }"

    input:
    // assembly should be gfa
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("${prefix}_reoriented.gfa.gz"), emit: gfa
    tuple val(meta), path("${prefix}_all_reorientation_summary.tsv"), emit: tsv
    tuple val(meta), path("${prefix}_MMseqs2_output.txt"), emit: txt
    tuple val(meta), path("${prefix}.log"), emit: log
    tuple val(meta), path("logs/${prefix}_mmseqs.err"), emit: mmseqs_err
    tuple val(meta), path("logs/${prefix}_mmseqs.out"), emit: mmseqs_out
    tuple val("${task.process}"), val('dnaapler'), eval('dnaapler --version'), emit: versions_dnaapler, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    dnaapler \\
        all \\
        -i ${assembly} \\
        -o . \\
        ${args} \\
        -t ${task.cpus} \\
        -p ${prefix}
        
    gzip -c ${prefix}_reoriented.gfa > ${prefix}_reoriented.gfa.gz
    mv ${prefix}_*.log ${prefix}.log
    mv logs/*.err logs/${prefix}_mmseqs.err
    mv logs/*.out logs/${prefix}_mmseqs.out

    // cat <<-END_VERSIONS > versions.yml
    // "${task.process}":
    //     dnaapler: \$(samtools --version |& sed '1!d ; s/samtools //')
    // END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p logs
    echo stub | gzip -c > ${prefix}_reoriented.gfa.gz
    echo stub > ${prefix}_all_reorientation_summary.tsv
    echo stub > ${prefix}_MMseqs2_output.txt
    echo stub > ${prefix}.log
    echo stub > logs/${prefix}_mmseqs.err
    echo stub > logs/${prefix}_mmseqs.out

    // cat <<-END_VERSIONS > versions.yml
    // "${task.process}":
    //     dnaapler: \$(samtools --version |& sed '1!d ; s/samtools //')
    // END_VERSIONS
    """
}
