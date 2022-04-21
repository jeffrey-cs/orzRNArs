#!/usr/bin/env nextflow

params.subdir   = 'qc'

process FastQC{
  tag {smp}

  errorStrategy 'finish'
  cpus 1

  publishDir "${params.outdir}/${params.subdir}/${smp}",
    mode: params.savemode,
    overwrite: params.overwrite

  input:
  tuple val(smp), path("*")

  output:
  path("*.{zip,html}")

  script:
  """
  fastqc *.fq.gz
  """
}

process MultiQC{
  tag "Combining"

  errorStrategy 'finish'
  cpus 1

  publishDir "${params.outdir}/${params.subdir}/",
    mode: params.savemode,
    overwrite: params.overwrite

  input:
  path("*")

  output:
  path("*")

  script:
  """
  multiqc .
  """
}

