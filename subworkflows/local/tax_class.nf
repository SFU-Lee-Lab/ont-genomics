// import modules
include { krona; aggregate_krona_split; aggregate_kreport_split } from '../../modules/local/taxonomy_class.nf'
include { CENTRIFUGER_CENTRIFUGER } from '../../modules/nf-core/centrifuger/centrifuger/main.nf'
include { CENTRIFUGER_QUANTIFICATION     } from '../../modules/nf-core/centrifuger/quantification/main.nf'
include { KRAKENTOOLS_KREPORT2KRONA } from '../../modules/nf-core/krakentools/kreport2krona/main.nf'
include { KRONA_KTIMPORTTAXONOMY } from '../../modules/nf-core/krona/ktimporttaxonomy/main.nf'
include { KRONA_KTUPDATETAXONOMY } from '../../modules/nf-core/krona/ktupdatetaxonomy/main.nf'
include { KRONA_KTIMPORTKRONA } from '../../modules/nf-core/krona/ktimportkrona/main.nf'

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
        // parse the most abundance species assignment from centrifuger report
        ch_species = CENTRIFUGER_QUANTIFICATION.out.report_file
            .map { meta, report ->
                species = report.readLines()
                        .findAll { it.split('\t')[3] == 'S' }
                        .max { it.split('\t')[2].toDouble() }
                        .split('\t')[5]
                        .trim()
                        .replace('_', ' ')
                if ( species == 'Clostridioides difficile' ) {
                    species = 'Clostridium difficile'
                }
                return tuple(meta, species)
            }
        // print species assignment to screen
        ch_species.subscribe { meta, species ->
            println "Sample \u001B[93m${meta.id}\u001B[0m was assigned to: \u001B[92m${species}\u001B[0m"
        }
        // convert kraken report to krona format
        KRAKENTOOLS_KREPORT2KRONA(CENTRIFUGER_QUANTIFICATION.out.report_file)

        // build krona interactive reports
        if ( !params.krona_taxdb ) {
            KRONA_KTUPDATETAXONOMY()
            ch_taxdb = KRONA_KTUPDATETAXONOMY.out.db
        } else {
            ch_taxdb = Channel.fromPath(
                params.krona_taxdb, 
                checkIfExists: true,
                type: 'dir'
            )
        }

        KRONA_KTIMPORTTAXONOMY(KRAKENTOOLS_KREPORT2KRONA.out.txt, ch_taxdb.first())
        KRONA_KTIMPORTKRONA(KRONA_KTIMPORTTAXONOMY.out.html.map { it[1] }.collect())
        
    emit:
        species_id = ch_species
}