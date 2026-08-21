// import workflows
// include { ANNOT } from '../subworkflows/local/genome_annotation.nf'
include { ASSEMBLY_QC } from '../subworkflows/local/assembly_qc.nf'
include { ASSEMBLY_COV } from '../subworkflows/local/assembly_cov.nf'

// import modules
include { combine_res } from '../modules/local/parse.nf'
include { nanocomp_dir } from '../modules/local/nanopore-base.nf'

workflow POST_ASM_PROCESS {

    take: assembly // Path: assembly path
          reads       // Path: filtered raw read path

    main:
        
        // COVERAGE analysis
        ASSEMBLY_COV(reads, assembly)

        // run sequence QC
        // if ( params.qc ) { 
                
        //     ASSEMBLY_QC(assembly, reads)

        //     // combined all post-assembly QC results into a master CSV/TSV report
        //     combine_res(
        //         ASSEMBLY_QC.out.checkm_res,
        //         ASSEMBLY_QC.out.quast_res
        //     )
        // }

        // genome annotation
        // if ( params.annot  ) { 

        //     ANNOT(assembly)

        // }

        
}