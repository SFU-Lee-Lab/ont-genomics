// import modules
include { flye } from '../modules/local/nanopore-assembly.nf'
include { medaka; medaka_gpu } from '../modules/local/nanopore-polish.nf'
include { rename_FASTA } from '../modules/local/rename_FASTA/rename_FASTA.nf'

workflow ASSEMBLY_NANOPORE {
    take: reads
    main:

        // only perform assemblies on samples with >N reads
        asm_reads = reads.filter{ it[1].countFastq() >= params.min_tr }
        
        // run assembly workflow
        flye(asm_reads)

        // run polishing
        if (params.gpu) {

            assembly
            | join(asm_reads)
            | medaka_gpu
            | set { polished_asm }

        } else {
            
            assembly
            | join(asm_reads)
            | medaka
            | set { polished_asm }

        }
        
        assembly_out = polished_asm
                    
               
    emit: assembly_out
}