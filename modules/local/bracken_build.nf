process BRACKEN_BUILD {
    tag "${meta.id}-${options.kmer_length}-${read_lengths}"
    label 'process_high'
  
    conda (params.enable_conda ? 'bioconda::bracken=2.7 bioconda::kraken=2.1.2' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bracken:2.7--py39hc16433a_0':
        'quay.io/biocontainers/bracken:2.7--py39hc16433a_0' }"
  
    input:
    tuple val(meta), path(taxonomy, stageAs: 'taxonomy/*'), path(custom_library, stageAs: 'library/added/*'), path(kraken, stageAs: 'kraken/*'), val(options), val(read_lengths)
  
    output:
    tuple val(meta), path("${prefix}/taxonomy/*", includeInputs: true), path("${prefix}/library/added/*", includeInputs: true), path("${prefix}/*.{k2d,map}", includeInputs: true), val(options), path("${prefix}/*.{kmer_distrib,kraken}", includeInputs: true), val(read_lengths), emit: db
  
    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    commands = read_lengths.collect { "bracken-build -d '${prefix}' -t ${task.cpus} -k ${options.kmer_length} -l ${it}" }.join('\n')
    """
    mkdir '${prefix}'
    mv taxonomy '${prefix}/'
    mv library '${prefix}/'
    mv kraken/* '${prefix}/'

    ${commands}
    """
}