#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// import native java libraries
import java.nio.file.Paths

// validate user-supplied parameters
WorkflowMain.initialise(workflow, params, log)

// import workflows
include { NANOPORE } from './workflow/nanopore.nf'
include { post_asm_process } from './workflow/post_asm_process.nf'
include { rename_FASTQ } from './modules/local/rename_FASTQ/rename_FASTQ.nf'
include { taxonkit_name2taxid } from './modules/local/taxonkit/name2taxid.nf'
include { rename_FASTA } from './modules/local/rename_FASTA/rename_FASTA.nf'

// define main workflow
workflow {
    
    // read data
    if (params.input) {

        // input: path to samplesheet CSV file
        log.info "${workflow.manifest.name}: Detected samplesheet CSV passed as input."

        data = channel
            .fromPath(params.input, checkIfExists: true)
            .splitCsv(header: false)
            .map { id, path -> // convert channel items to tuple following nf-core standard
                [ [id: id ], path ]
            }
            .branch{ id,path ->
                reads: file(path).isDirectory()
                asm: ( ! file(path).isDirectory() ) & ['.fa', '.fasta', '.fna'].any { path.endsWith(it) }
            }
        
        rename_FASTA(data.asm)

    } else if (params.input_dir) {

        // input_dir: directory path containing multiple barcodes, each as with own subdirectory
        log.warn "Detected directory path passed as input."

        // construct data channel
        barcode_dirs = file(params.input_dir)
            .listFiles()
            .findAll { f -> f.isDirectory() }

        if ( barcode_dirs.size() == 0 ) {
            log.error "No sample/barcode subdirectories found under ${params.input_dir}"
            System.exit(1)
        }

        data = channel.fromList(
            barcode_dirs.collect { d ->
                [d.name, file(d.toString())]
            }
        )
        .branch{ id,path ->
                reads: file(path).isDirectory()
                asm: ( ! file(path).isDirectory() ) & ['.fa', '.fasta', '.fna'].any { path.endsWith(it) }
        }
        
        rename_FASTA(data.asm)


    } else {

        data = Channel.empty()
        log.error "${workflow.manifest.name}: No valid inputs were provided."
        System.exit(1)

    }     

    // start analysis
    NANOPORE(data.reads)
    // taxid = taxonkit_name2taxid(params.taxon_name)
    
    // set up analysis input channels
    // for assembly inputs
    // ch_asm   = data.asm.map { id,path ->
    //     [id, [] ]
    // }
    // // for reads
    // ch_reads = data.reads
    // // merge reads and asm channels
    // ch_combined = ch_reads.concat(ch_asm)
    

    // post_asm_process(nanopore.out.assembly, nanopore.out.reads, false)

    // process genome assembly directly
    // post_asm_process_asm(rename_FASTA.out, data.asm.map { id,path -> [id, [] ] }, taxid, true)
    
}