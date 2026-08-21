// import modules
include { QUAST } from '../../modules/nf-core/quast/main.nf'
include { CHECKM_LINEAGEWF } from '../../modules/nf-core/checkm/lineagewf/main.nf'
include { GUNC_RUN } from '../../modules/nf-core/gunc/run/main.nf'
include { SOURMASH_SKETCH } from '../../modules/nf-core/sourmash/sketch/main.nf'
include { SOURMASH_GATHER } from '../../modules/nf-core/sourmash/gather/main.nf'


workflow ASSEMBLY_QC {
    take: 
        assembly
        reads
    main:
        // QUAST on polished assembly
        QUAST(
            assembly,
            reads,
            [ [], [] ]
        )
        
        // checkm
        CHECKM_LINEAGEWF(
            assembly,
            ".fa.gz", // fasta extension
            params.checkm_db // db path
        )
        // CHECKM_LINEAGEWF.out.checkm_output.view()

        // gunc
        // GUNC_RUN(
        //     assembly,
        //     params.gunc_db
        // )
        // GUNC_RUN.out.maxcss_level_tsv.view()
        
        // sourmash
        SOURMASH_SKETCH(
            assembly
        )
        SOURMASH_GATHER(
            SOURMASH_SKETCH.out.signatures,
            params.sourmash_db,
            false,
            false,
            false,
            false
        )
        SOURMASH_GATHER.out.result.view()

    emit:
        quast_res = QUAST.out.results
}