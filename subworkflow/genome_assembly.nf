// import modules
include { flye } from '../modules/local/nanopore-assembly.nf'
include { medaka; medaka_gpu } from '../modules/local/nanopore-polish.nf'
include { rename_FASTA } from '../modules/local/rename_FASTA/rename_FASTA.nf'

workflow ASSEMBLY_nanopore {
    take: reads
    main:
        // define assembly opts for target wgs and metagenomics
        flye_opts=""

        // only perform assemblies on samples with >N reads
        asm_reads = reads.filter{ it[1].countFastq() >= params.min_tr }
        
        // run assembly workflow
        if ( params.meta != 'off' ) {
            
            metaflye(asm_reads, flye_opts)
            assembly_out = metaflye.out.fasta
            
        } else {
            
            flye(asm_reads, flye_opts)
            
            if (!params.nopolish) {
                // split assemblies by contig count
                assembly = flye.out.fasta.branch { id, fasta ->
                    small: fasta.countFasta() <= 30
                    large: fasta.countFasta() > 30
                }
                // assembly.small.view { "$it is small" }
                // assembly.large.view { "$it is large" }
                // polish those with low contig count
                if (params.gpu) {

                    assembly.small
                        | join(asm_reads)
                        | medaka_gpu
                        | set { polished_asm }

                    } else {
                        
                        assembly.small
                            | join(asm_reads)
                            | medaka
                            | set { polished_asm }

                    }
                    // skip polishing for highly fragmented assemblies
                    rename_FASTA(assembly.large)
                    assembly_out = Channel.empty().mix(assembly.large, polished_asm)
                } else {
                    rename_FASTA(flye.out.fasta)
                    assembly_out = rename_FASTA.out
                }            
        }
               
    emit: assembly_out
}