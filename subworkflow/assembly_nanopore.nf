// import modules
include { FLYE } from '../modules/nf-core/flye/main.nf'
include { MEDAKA } from '../modules/nf-core/medaka/main.nf'
include { QUAST } from '../modules/nf-core/quast/main.nf'

workflow ASSEMBLY_NANOPORE {
    take: reads
    main:

        // only perform assemblies on samples with >N reads
        ch_asm_reads = reads.filter{ it[1].countFastq() >= params.min_nr_asm }
        
        // run assembly workflow
        ch_FLYE_mode = Channel.of('--nano-hq').first()
        FLYE(ch_asm_reads, ch_FLYE_mode)
        ch_asm = FLYE.out.fasta

        // calculate coverage using QUAST
        QUAST(
            ch_asm, 
            ch_asm_reads, 
            [ [], [] ]
        )

        // parse QUAST tsv
        ch_asm_cov = QUAST.out.tsv.map { meta, tsv ->
                def coverage = tsv.readLines().find {
                    it.startsWith('Avg. coverage depth') 
                }.split('\t')[1].toDouble()
                
                return tuple(meta, coverage)
            }

        // retain those ch_asm_cov items that have coverage >= params.min_asm_cov
        ch_asm_cov_filtered = ch_asm_cov.filter { meta, cov ->
                cov >= params.min_asm_cov
            }
            .join(ch_asm, by:0)
            .map { meta, cov, asm -> 
                tuple(meta, asm)
            }

        // run polishing
        // MEDAKA(ch_asm_reads.join(ch_asm))        
        // ch_polished_asm = MEDAKA.out.assembly
                    
    emit: 
        raw_asm = ch_asm // unpolished flye assembly
        // polished_asm = ch_polished_asm
}