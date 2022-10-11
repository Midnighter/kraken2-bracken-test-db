#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
nextflow.preview.recursion = true

/*****************************************************************************
* Local Imports
****************************************************************************/
  
include { KRAKEN2_BUILD_DOWNLOAD_TAXONOMY } from './modules/local/kraken2_build_download_taxonomy'
include { PREPARE_BARE_DATABASE } from './modules/local/prepare_bare_database'
include { KRAKEN2_BRACKEN_DATABASE } from './workflows/local/kraken2_bracken_database'
  
/*****************************************************************************
* Implicit Main Workflow
****************************************************************************/
  
workflow {
    log.info """
************************************************************

Build Kraken2 & Bracken Database
================================
Database Name:     ${params.database}
Taxonomy:          ${params.taxonomy ?: 'NCBI'}
Prepared Library:  ${params.prepared_library ?: ''}
Custom Library:    ${params.custom_library}
K-mer Length:      ${params.kmer_length}
Minimizer Length:  ${params.minimizer_length}
Minimizer Spaces:  ${params.minimizer_spaces}
Read Length:       ${params.read_lengths}
Results Directory: ${params.outdir}

************************************************************
  
    """

    def ch_bare_database
    if (params.taxonomy) {
        def ch_input_taxonomy = Channel.of([id: params.database, database: params.database])
            .combine(
                Channel.fromPath(params.taxonomy, checkIfExists: true)
            )

        ch_bare_database = PREPARE_BARE_DATABASE(ch_input_taxonomy).taxonomy
    } else {
        def ch_input_taxonomy = Channel.of([id: params.database, database: params.database])

        // Download the NCBI taxonomy.
        ch_bare_database = KRAKEN2_BUILD_DOWNLOAD_TAXONOMY(ch_input_taxonomy).taxonomy
    }

    def ch_prepared_libraries = params.prepared_library ? Channel.fromList(params.prepared_library.split(',').toList()) : Channel.empty()

    def ch_custom_libraries = params.custom_library ? Channel.fromPath(params.custom_library.split(',').toList(), checkIfExists: true) : Channel.empty()

    KRAKEN2_BRACKEN_DATABASE(
        ch_bare_database,
        ch_prepared_libraries,
        ch_custom_libraries,
        Channel.fromList(params.kmer_length.split(',').toList()),
        Channel.fromList(params.minimizer_length.split(',').toList()),
        Channel.fromList(params.minimizer_spaces.split(',').toList()),
        Channel.fromList(params.read_lengths.split(',').toList())
    )

}
