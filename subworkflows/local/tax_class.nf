// import modules
include { krona; aggregate_krona_split; aggregate_kreport_split } from '../../modules/local/taxonomy_class.nf'
include { CENTRIFUGER_CENTRIFUGER } from '../../modules/nf-core/centrifuger/centrifuger/main.nf'
include { CENTRIFUGER_QUANTIFICATION     } from '../../modules/nf-core/centrifuger/quantification/main.nf'

workflow TAX_CLASS {
    take: 
        reads
    main:
        centrifuger_db=Channel.fromPath(
            params.centrifuger_db, 
            checkIfExists: true,
            type: 'dir'
        )
        .map { db -> tuple([id: 'centrifuger_db'], db)}

        CENTRIFUGER_CENTRIFUGER(
            reads, 
            centrifuger_db.first(),
            false, // save unclassified reads
            false, // save classified reads
            [], // barcode
            []  // umi
        )

        CENTRIFUGER_QUANTIFICATION(
            CENTRIFUGER_CENTRIFUGER.out.classification_file,
            centrifuger_db.first(),
            [],
            [],
            []
        )



        // kreport = centrifuge.out.kreport.map{ it[1] }.collect() // collect all centrifuge reports into a list

        // // create Krona report
        // centrifuge.out.krona 
        // | collect
        // | map { it[1] }
        // | krona
        
    // emit:
        // kreport = kreport
}