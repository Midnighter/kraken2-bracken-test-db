process KRAKEN2_BUILD_CLEAN {
    tag "${meta.id}"
    label 'process_single'
  
    conda (params.enable_conda ? 'bioconda::kraken=2.1.2' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kraken2:2.1.2--pl5321h9f5acd7_2':
        'quay.io/biocontainers/kraken2:2.1.2--pl5321h9f5acd7_2' }"
  
    input:
    tuple(
        val(meta),
        path(taxonomy, stageAs: 'taxonomy/*'),
        path(custom_library, stageAs: 'library/added/*'),
        path(kraken, stageAs: 'kraken/*'),
        val(options),
        path(bracken, stageAs: 'bracken/*'),
        val(read_lengths)
    )
  
    output:
    tuple(
        val(meta),
        path("${prefix}/*.k2d"),
        path("${prefix}/*.{kmer_distrib,kraken}"),
        val(options),
        emit: db
    )

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    mkdir '${prefix}'
    mv taxonomy '${prefix}/'
    mv library '${prefix}/'
    mv kraken/* '${prefix}/'
    mv bracken/* '${prefix}/'

    kraken2-build \\
        --clean \\
        --db '${prefix}'
    """
}