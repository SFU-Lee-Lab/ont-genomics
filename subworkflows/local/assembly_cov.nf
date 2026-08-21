// import modules
include { MINIMAP2_PAIRED_ALIGN } from '../../modules/local/minimap2/align/main.nf'

workflow ASSEMBLY_COV {
    take: 
        reads
        reference_fasta
    main:

        ch_minimap2_input = reads.join(reference_fasta, by: 0)

        MINIMAP2_PAIRED_ALIGN(
            ch_minimap2_input,
            true,  // bam_format
            'bai',  // bam_index_extension
            false, // cigar_paf_format
            false  // cigar_bam
        )
        
    // emit:
        // kreport = kreport
}