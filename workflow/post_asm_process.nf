// import workflows
include { ANNOT } from '../subworkflows/local/genome_annotation.nf'
include { ASSEMBLY_QC } from '../subworkflows/local/assembly_qc.nf'

// import modules
include { combine_res } from '../modules/local/parse.nf'
include { nanocomp_dir } from '../modules/local/nanopore-base.nf'

workflow post_asm_process {

    take: ch_assembly // Path: assembly path
          reads       // Path: filtered raw read path

    main:
        
        // run sequence QC
        if ( params.qc ) { 
                
            ASSEMBLY_QC(assembly, reads)

            // combined all post-assembly QC results into a master CSV/TSV report
            combine_res(
                ASSEMBLY_QC.out.checkm_res,
                ASSEMBLY_QC.out.quast_res
            )
        }

        // genome annotation
        if ( params.annot  ) { 

            ANNOT(assembly)

        }

        
}