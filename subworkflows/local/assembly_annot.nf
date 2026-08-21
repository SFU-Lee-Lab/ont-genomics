// import modules
include { BAKTA_BAKTA } from '../../modules/nf-core/bakta/bakta/main.nf'

workflow ASSEMBLY_ANNOT {
    
    take: assembly // Tuple: [ meta, assembly ]

    main:

        // BAKTA annotation
        ch_bakta_db = Channel.fromPath(params.bakta_db, checkIfExists: true, type: 'dir')
        BAKTA_BAKTA(
            assembly,
            ch_bakta_db.first(), // db
            [], // proteins
            [], // prodigal_tf
            [], // regions
            []  // hmms
        )

}