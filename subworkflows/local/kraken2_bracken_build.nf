/*****************************************************************************
* Local Imports
****************************************************************************/

include { KRAKEN2_BUILD } from '../../modules/local/kraken2_build'
include { BRACKEN_BUILD } from '../../modules/local/bracken_build'

/*****************************************************************************
* Workflow
****************************************************************************/

workflow KRAKEN2_BRACKEN_BUILD {
    take:

    ch_taxonomy  // tuple val(meta), path(taxonomy)
    ch_prepared_library  // tuple val(meta), val(library)
    ch_custom_library  // tuple val(meta), path(library)
    ch_kmer_length  // val
    ch_minimizer_length  // val
    ch_minimizer_spaces  // val
    ch_read_length  // val

    main:

    // Generate kraken2 options combinations.
    def ch_kraken2_build_options = ch_kmer_length
        .combine(ch_minimizer_length)
        .combine(ch_minimizer_spaces)
        .map { kmer, length, spaces ->
            return [
                'kmer_length': kmer,
                'minimizer_length': length,
                'minimizer_spaces': spaces
            ]
        }

    // Build the kraken2 database from the taxonomy and all the libraries,
    // as well as parameter combinations.
    def ch_kraken2_build_input = Channel.empty()
        .concat(
            ch_taxonomy,
            // ch_prepared_library,
            ch_custom_library
        )
        .groupTuple()
        .combine(ch_kraken2_build_options)
        .map { meta, files, options ->
            return [meta, files.head(), files.tail().flatten(), options]
        }

    KRAKEN2_BUILD(ch_kraken2_build_input)

    def read_lengths = ch_read_length.collect().toList()

    // Create the bracken mappings using combinations of kraken2 build output,
    // empty Bracken input (to match output for recursion),
    // and the desired read lengths.
    def ch_bracken_build_input = KRAKEN2_BUILD.out.db
        .combine([[[]]])  // initially empty Bracken mappings
        .combine(read_lengths)

    def rec_input = ch_bracken_build_input.toList()[0]

    // println rec_input.getClass()

    // BRACKEN_BUILD
        // .recurse(rec_input, 0)
        // .times(read_lengths.size())

    // emit:

    // db = BRACKEN_BUILD.out.db
}