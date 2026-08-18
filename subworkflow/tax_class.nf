// import modules
include { centrifuge; krona; aggregate_krona_split; aggregate_kreport_split } from '../modules/local/taxonomy_class.nf'
include { seqkit_fx2tab } from '../modules/local/seqkit/fx2tab.nf'
include { nanocomp } from '../modules/local/nanopore-base.nf'

workflow TAX_CLASS {
    take: 
        reads
    main:
        centrifuge_db=file(params.centrifuge, checkIfExists: true)
        centrifuge(reads, centrifuge_db)

        kreport = centrifuge.out.kreport.map{ it[1] }.collect() // collect all centrifuge reports into a list

        // create Krona report
        centrifuge.out.krona 
        | collect
        | map { it[1] }
        | krona
        
    emit:
        kreport = kreport
}