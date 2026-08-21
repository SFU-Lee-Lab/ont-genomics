// import modules
include { MINIMAP2_PAIRED_ALIGN } from '../../modules/local/minimap2/align/main.nf'
include { SAMTOOLS_FAIDX } from '../../modules/nf-core/samtools/faidx/main.nf'
include { GUNZIP } from '../../modules/nf-core/gunzip/main.nf'

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

        GUNZIP(reference_fasta)

        SAMTOOLS_FAIDX(
            GUNZIP.out.gunzip.map { meta, fasta -> tuple(meta, fasta, []) },
            false
        )        
}