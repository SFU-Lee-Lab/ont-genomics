// import modules
include { FLYE } from '../modules/nf-core/flye/main.nf'
include { MEDAKA } from '../modules/nf-core/medaka/main.nf'

workflow ASSEMBLY_NANOPORE {
    take: reads
    main:

        // only perform assemblies on samples with >N reads
        ch_asm_reads = reads.filter{ it[1].countFastq() >= params.min_tr }
        
        // run assembly workflow
        ch_FLYE_mode = Channel.of('--nano-hq').first()
        FLYE(ch_asm_reads, ch_FLYE_mode)
        ch_asm = FLYE.out.fasta

        // run polishing
        MEDAKA(ch_asm_reads.join(ch_asm))        
        ch_polished_asm = MEDAKA.out.assembly
                    
    emit: 
        raw_asm = ch_asm
        polished_asm = ch_polished_asm
}