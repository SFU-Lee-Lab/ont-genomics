// import modules

workflow ANNOT {
    take: assembly
    main:
        

    emit:
        rgi_combined_flat \
            | concat(abricate_combined_flat, mob_suite_combined_flat) \
            | collect
}