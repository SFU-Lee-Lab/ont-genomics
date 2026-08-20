// import modules
include { checkm_single; aggregate_checkm } from '../../modules/local/checkm.nf'
include { quast; aggregate_quast; } from '../../modules/local/quast.nf'

workflow ASSEMBLY_QC {
    take: 
        assembly
        reads
    main:
        // CheckM
        assembly 
        | checkm_single
        | map { it[1] }
        | collect
        | aggregate_checkm
        | set { aggregate_checkm }


        // QUAST
        assembly
        | join(reads)
        | set { quast_input }
        
        quast(quast_input)

        quast.out
        | map { it[1] }
        | collect
        | aggregate_quast
        | set { aggregate_quast }

    emit:
        checkm_res = aggregate_checkm
        quast_res = aggregate_quast
}