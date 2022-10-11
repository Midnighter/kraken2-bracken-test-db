process PREPARE_BARE_DATABASE {
    tag "${meta.id}"
    label 'process_single'
  
    conda (params.enable_conda ? 'conda-forge::bash=5.0' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://containers.biocontainers.pro/s3/SingImgsRepo/biocontainers/v1.2.0_cv2/biocontainers_v1.2.0_cv2.img':
        'biocontainers/biocontainers:v1.2.0_cv2' }"
  
    input:
    tuple val(meta), path(taxonomy, stageAs: 'taxonomy/*')
  
    output:
    tuple val(meta), path("${meta.id}/taxonomy/*"), emit: taxonomy
  
    script:
    """
    mkdir '${meta.id}'
    mv taxonomy '${meta.id}/'
    """
}