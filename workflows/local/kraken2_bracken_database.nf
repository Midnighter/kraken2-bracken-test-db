/*****************************************************************************
* Local Imports
****************************************************************************/

include { KRAKEN2_BUILD_DOWNLOAD_LIBRARY } from '../../modules/local/kraken2_build_download_library'
include { KRAKEN2_BUILD_ADD_LIBRARY } from '../../modules/local/kraken2_build_add_library'
include { KRAKEN2_BUILD_CLEAN } from '../../modules/local/kraken2_build_clean'
include { KRAKEN2_BRACKEN_BUILD } from '../../subworkflows/local/kraken2_bracken_build'

/*****************************************************************************
* Workflow
****************************************************************************/

workflow KRAKEN2_BRACKEN_DATABASE {
    take:

    bare_database
    prepared_library
    custom_library
    kmer_length
    minimizer_length
    minimizer_spaces
    read_length

    main:

    def ch_download_library_input = bare_database
        .combine(prepared_library)
        .multiMap { meta, taxonomy, library ->
            taxonomy: [meta, taxonomy]
            library: library
        }

    def ch_prepared_library = KRAKEN2_BUILD_DOWNLOAD_LIBRARY(
        ch_download_library_input.taxonomy,
        ch_download_library_input.library
    ).library

    def ch_add_library_input = bare_database
        .combine(custom_library)
        .multiMap { meta, taxonomy, library ->
            taxonomy: [meta, taxonomy]
            library: library
        }

    def ch_custom_library = KRAKEN2_BUILD_ADD_LIBRARY(
        ch_add_library_input.taxonomy,
        ch_add_library_input.library
    ).library

    KRAKEN2_BRACKEN_BUILD(
        bare_database,
        ch_prepared_library,
        ch_custom_library,
        kmer_length,
        minimizer_length,
        minimizer_spaces,
        read_length
    )

    KRAKEN2_BUILD_CLEAN(KRAKEN2_BRACKEN_BUILD.out.db)

    emit:

    db = KRAKEN2_BUILD_CLEAN.out.db
}