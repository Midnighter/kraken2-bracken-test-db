process KRAKEN2_BUILD_CLEAN {
    tag "${meta.id}"
    label 'process_single'
  
    conda (params.enable_conda ? 'bioconda::kraken=2.1.2' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kraken2:2.1.2--pl5321h9f5acd7_2':
        'quay.io/biocontainers/kraken2:2.1.2--pl5321h9f5acd7_2' }"
  
    input:
    tuple val(meta), path(taxonomy, stageAs: 'taxonomy/*'), path(custom_library, stageAs: 'library/added/*'), path(kraken, stageAs: 'kraken/*'), path(bracken, stageAs: 'bracken/*'), val(options)
  
    output:
    tuple val(meta), path("${meta.id}/*.k2d"), path("${meta.id}/*.{kmer_distrib,kraken}"), val(options), emit: db

    script:
    """
    mkdir '${meta.id}'
    mv taxonomy '${meta.id}/'
    mv library '${meta.id}/'
    mv kraken/* '${meta.id}/'
    mv bracken/* '${meta.id}/'

    kraken2-build \\
        --clean \\
        --db '${meta.id}'
    """
}