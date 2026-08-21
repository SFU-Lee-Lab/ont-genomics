// import workflows
// include { ANNOT } from '../subworkflows/local/genome_annotation.nf'
include { ASSEMBLY_QC } from '../subworkflows/local/assembly_qc.nf'
include { ASSEMBLY_COV } from '../subworkflows/local/assembly_cov.nf'
include { ASSEMBLY_ANNOT } from '../subworkflows/local/assembly_annot.nf'

// import modules
include { combine_res } from '../modules/local/parse.nf'

workflow POST_ASM_PROCESS {

    take: assembly // Path: assembly path
          reads    // Path: filtered raw read path

    main:

        // run sequence QC
        if ( params.qc ) { 
                
            // post-assembly QC
            ASSEMBLY_QC(assembly, reads)
            
            // COVERAGE analysis
            ASSEMBLY_COV(reads, assembly)

            // // combined all post-assembly QC results into a master CSV/TSV report
            // combine_res(
            //     ASSEMBLY_QC.out.checkm_res,
            //     ASSEMBLY_QC.out.quast_res
            // )
        }

        // genome annotation
        if ( params.annot  ) { 

            ASSEMBLY_ANNOT(assembly)

        }

        
}