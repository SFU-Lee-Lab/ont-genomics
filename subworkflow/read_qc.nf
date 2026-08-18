// import modules
include { porechop; nanoq } from '../modules/local/nanopore-base.nf'
include { nanocomp as nanocomp_before; nanocomp as nanocomp_after; nanocomp as nanocomp_trimmed } from '../modules/local/nanopore-base.nf'

// define nanopore workflow
workflow READ_QC {
    
    take: reads // [ [id:], path ]

    main:        

        // adaptor and barcode trimming
        if ( params.trim ) { 
            
            ch_trimmed_reads = porechop(reads)

        } else {
            
            ch_trimmed_reads = reads

        }

        // quality filtering on raw reads
        ch_filtered_reads = nanoq(ch_trimmed_reads)

    emit:
        clean_reads = ch_filtered_reads
}