process TAR_ARCHIVE {
    tag "${meta.id}"
    label 'process_single'

    conda (params.enable_conda ? "conda-forge::tar=1.32" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://containers.biocontainers.pro/s3/SingImgsRepo/biocontainers/v1.2.0_cv2/biocontainers_v1.2.0_cv2.img' :
        'biocontainers/biocontainers:v1.2.0_cv2' }"

    input:
    tuple val(meta), path(files)

    output:
    tuple val(meta), path('*.tar.gz'), emit: tar
    path 'versions.yml'              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: '--dereference'
    def prefix = task.ext.prefix ?: meta.id
    def names = files instanceof List ? files.collect { "'${it}'" }.join(' ') : "'${files}'"
    """
    tar ${args} -czf '${prefix}.tar.gz' ${names}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tar: \$(echo \$(tar --version 2>&1) | sed 's/^.*(GNU tar) //; s/ Copyright.*\$//')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: '--dereference'
    def prefix = task.ext.prefix ?: meta.id
    def names = files instanceof List ? files.collect { "'${it}'" }.join(' ') : "'${files}'"
    """
    echo tar ${args} -czf '${prefix}.tar.gz' ${names}
    touch '${prefix}.tar.gz'

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tar: \$(echo \$(tar --version 2>&1) | sed 's/^.*(GNU tar) //; s/ Copyright.*\$//')
    END_VERSIONS
    """
}
