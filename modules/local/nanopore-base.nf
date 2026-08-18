// basic processes for Nanopore workflows
process combine {
    tag "Combining FASTQ files for ${sample_id}"
    label "process_low"

    input:
        tuple val(meta), path(reads)
    output:
        tuple val(meta), file("${meta.id}.{fastq,fastq.gz}")
    shell:
        """
        sample=\$(ls ${reads} | head -n 1)
        if [[ \${sample##*.} == "gz" ]]; then
            ext="fastq.gz"
            cat_cmd="zcat"
        else
            ext="fastq"
            cat_cmd="cat"
        fi
        cat ${reads}/*.\$ext > ${meta.id}.\$ext
        # verify file integrity
        \$cat_cmd ${meta.id}.\$ext | \
            awk 'NR%4==2 || NR%4==0' | \
            paste - - | \
            awk '{if(length(\$1) != length(\$2)) {print "Read " NR/4 " has different number of bases and quality scores"; exit 1}}' \
            > /dev/null
        \$cat_cmd ${meta.id}.\$ext > /dev/null
        """
}

process porechop {
    tag "Adaptor trimming on ${sample_id}"
    label "process_medium"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}_trimmed.fastq")
    shell:
        """
        porechop -t ${task.cpus} -i ${reads} -o ${sample_id}_trimmed.fastq
        """
}

process nanoq {
    tag "Read filtering on ${sample_id}"
    label "process_low"
    cache true
    // publishDir "$params.out_dir"+"/reads/", mode: "copy"

    input:
        tuple val(sample_id), path(reads)
    output:
        tuple val(sample_id), file("${sample_id}.filt.fastq.gz")
    shell:
        """
        nanoq -i ${reads} -l ${params.min_rl} -q ${params.min_rq} -O g > ${sample_id}.filt.fastq.gz
        """
}

process nanocomp {
    tag "Generating raw read QC with NanoPlot"
    label "process_low"

    input:
        path(reads)
    output:
        path("NanoComp-report.html"), emit: report_html
        path("NanoStats.txt"), emit: stats_tsv
        path("NanoComp-data.tsv.gz"), emit: data
    shell:
        """
        NanoComp -t ${task.cpus} --tsv_stats --raw --fastq *.fastq* --names \$(ls | sed 's/.fastq.*//g') -o .
        """
}

process nanocomp_dir {
    tag "Generating raw read QC with NanoPlot"
    label "process_low"
    maxForks 1

    input:
        tuple path(dir), path(work)
    output:
        path("NanoComp-report.html"), emit: report_html
        path("NanoStats.txt"), emit: stats_tsv
        path("NanoComp-data.tsv.gz"), emit: data
    shell:
        """
        id=\$(find -L ${dir} -type f -name '*.fastq.gz' | sed 's/.*_TIME_//g' | sed 's/.filt.fastq.gz//g' | sort -u)
        fastq=""
        for i in \$id; do fastq+=\$(find -L ${dir} -type f | grep \$i.filt.fastq.gz | sort -r | head -n1); fastq+=" "; done
        NanoComp -t ${task.cpus} --tsv_stats --raw --fastq \$fastq --names \$(echo \$fastq | sed 's/ /\\n/g' | sed 's/.*_//g' | sed 's/.filt.fastq.gz//g' | tr '\\n' ' ') -o .
        """
}
