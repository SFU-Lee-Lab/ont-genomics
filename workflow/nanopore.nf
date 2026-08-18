// import modules
import java.nio.file.Files
include { porechop; combine; nanoq; combine_watch; fastq_watch } from '../modules/local/nanopore-base.nf'

// import subworkflow
include { ASSEMBLY_nanopore } from '../subworkflow/genome_assembly.nf'

// define nanopore workflow
workflow nanopore {
    
    take: data

    main:
        
        // combine reads
        combine(data)
            | set { combined_reads }
        

        // trimming
        if ( params.trim ) { 
            
            reads = porechop(combined_reads)

        } else {
            
            reads = combined_reads

        }

        // keep only non-empty FASTQ
        reads_out = nanoq(reads).filter { id, fastq -> fastq.countFastq() > 0 }

        // assembly
        ASSEMBLY_nanopore(reads_out)
        
    emit:
        assembly = ASSEMBLY_nanopore.out
        reads = reads_out
}