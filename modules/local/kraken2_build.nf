process KRAKEN2_BUILD {
    tag "${meta.id}-${options.kmer_length}-${options.minimizer_length}-${options.minimizer_spaces}"
    label 'process_high'
  
    conda (params.enable_conda ? 'bioconda::kraken=2.1.2' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kraken2:2.1.2--pl5321h9f5acd7_2':
        'quay.io/biocontainers/kraken2:2.1.2--pl5321h9f5acd7_2' }"
  
    input:
    tuple val(meta), path(taxonomy, stageAs: 'taxonomy/*'), path(custom_library, stageAs: 'library/added/*'), val(options)
  
    output:
    tuple val(meta), path("${meta.id}/taxonomy/*"), path("${meta.id}/library/added/*"), path("${meta.id}/*.{k2d,map}"), val(options), emit: db
  
    script:
    """
    mkdir '${meta.id}'
    mv taxonomy '${meta.id}/'
    mv library '${meta.id}/'

    kraken2-build \\
        --build \\
        --db '${meta.id}' \\
        --threads ${task.cpus} \\
        --kmer-len ${options.kmer_length} \\
        --minimizer-len ${options.minimizer_length} \\
        --minimizer-spaces ${options.minimizer_spaces}
    """
}