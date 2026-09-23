// import modules
include { porechop  } from '../../modules/local/nanopore-base.nf'
include { NANOQ; NANOQ as NANOQ_PREFILTER } from '../../modules/nf-core/nanoq/main.nf'

// define nanopore workflow
workflow READ_QC {
    
    take: reads // [ [id:], path ]

    main:        
        // quality filtering on raw reads
        ch_NANOQ_output_fmt = Channel.of('fastq.gz').first()
        NANOQ_PREFILTER(reads, ch_NANOQ_output_fmt)
        NANOQ(reads, ch_NANOQ_output_fmt)
        ch_filtered_reads = NANOQ.out.reads

    emit:
        clean_reads = ch_filtered_reads
}