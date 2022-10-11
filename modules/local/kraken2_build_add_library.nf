process KRAKEN2_BUILD_ADD_LIBRARY {
    tag "${meta.id}"
    label 'process_single'
  
    conda (params.enable_conda ? 'bioconda::kraken=2.1.2' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kraken2:2.1.2--pl5321h9f5acd7_2':
        'quay.io/biocontainers/kraken2:2.1.2--pl5321h9f5acd7_2' }"
  
    input:
    tuple val(meta), path(taxonomy, stageAs: 'taxonomy/*')
    path library
  
    output:
    tuple val(meta), path("${prefix}/library/added/*"), emit: library

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    mkdir '${prefix}'
    mv taxonomy '${prefix}/'

    kraken2-build --db '${prefix}' --add-to-library '${library}'
    """
}