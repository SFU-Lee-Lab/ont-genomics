// import modules
include { combine } from '../modules/local/nanopore-base.nf'

// import subworkflow
include { ASSEMBLY_NANOPORE } from '../subworkflows/local/assembly_nanopore.nf'
include { READ_QC } from '../subworkflows/local/read_qc.nf'
include { TAX_CLASS } from '../subworkflows/local/tax_class.nf'

// define nanopore workflow
workflow NANOPORE {
    
    take: data

    main:
        
        // combine reads
        combined_reads = combine(data)

        // Raw read QC
        READ_QC(combined_reads)

        // keep only non-empty FASTQ
        ch_clean_reads = READ_QC.out.clean_reads.filter { meta, fastq -> 
            fastq.countFastq() > 0 
        }

        // taxonomic classification
        TAX_CLASS(ch_clean_reads)

        // assembly
        ASSEMBLY_NANOPORE(ch_clean_reads)
        
    emit:
        assembly = ASSEMBLY_NANOPORE.out.polished_asm
        reads = ch_clean_reads
}