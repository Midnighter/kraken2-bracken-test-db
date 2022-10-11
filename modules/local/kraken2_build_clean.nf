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
    // `includeInputs` is not necessary due to files being moved but makes explicit
    // that we pass through inputs.
    tuple(
        val(meta),
        path("${prefix}/*.k2d", includeInputs: true),
        path("${prefix}/*.{kmer_distrib,kraken}", includeInputs: true),
        val(options),
        emit: db
    )

    when:
    task.ext.when == null || task.ext.when

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