process BRACKEN_BUILD {
    tag "${meta.id}-${options.kmer_length}-${read_lengths[idx]}"
    label 'process_high'
  
    conda (params.enable_conda ? 'bioconda::bracken=2.7 bioconda::kraken=2.1.2' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bracken:2.7--py39hc16433a_0':
        'quay.io/biocontainers/bracken:2.7--py39hc16433a_0' }"
  
    input:
    tuple val(meta), path(taxonomy, stageAs: 'taxonomy/*'), path(custom_library, stageAs: 'library/added/*'), path(kraken, stageAs: 'kraken/*'), val(options), path(bracken, stageAs: 'bracken/*'), val(read_lengths)
    val idx
  
    output:
    tuple val(meta), path("${meta.id}/taxonomy/*", includeInputs: true), path("${meta.id}/library/added/*", includeInputs: true), path("${meta.id}/*.{k2d,map}", includeInputs: true), val(options), path("${meta.id}/*.{kmer_distrib,kraken}", includeInputs: true), val(read_lengths)
    val next_idx
  
    script:
    next_idx = idx + 1
    """
    mkdir '${meta.id}'
    mkdir -p bracken
    mv taxonomy '${meta.id}/'
    mv library '${meta.id}/'
    mv kraken/* '${meta.id}/'
    mv bracken/* '${meta.id}/'

    bracken-build \
        -d '${meta.id}' \
        -t ${task.cpus} \
        -k ${options.kmer_length} \
        -l ${read_lengths[idx]}
    """
}