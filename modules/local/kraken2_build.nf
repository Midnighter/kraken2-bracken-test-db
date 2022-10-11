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
    tuple val(meta), path("${prefix}/taxonomy/*"), path("${prefix}/library/added/*"), path("${prefix}/*.{k2d,map}"), val(options), emit: db
  
    script:
    prefix = task.ext.prefix ?: meta.id
    """
    mkdir '${prefix}'
    mv taxonomy '${prefix}/'
    mv library '${prefix}/'

    kraken2-build \\
        --build \\
        --db '${prefix}' \\
        --threads ${task.cpus} \\
        --kmer-len ${options.kmer_length} \\
        --minimizer-len ${options.minimizer_length} \\
        --minimizer-spaces ${options.minimizer_spaces}
    """
}