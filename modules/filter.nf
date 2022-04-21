#!/usr/bin/env nextflow

params.se         = false
params.subdir     = 'filter'
params.thread     = 4
params.savemode   = 'link'
params.overwrite  = true

process Fastp{
  tag {smp}

  errorStrategy 'finish'
  cpus params.thread

  publishDir "${params.outdir}/${params.subdir}/${smp}",
    mode: params.savemode,
    overwrite: params.overwrite

  input:
  tuple val(smp), path("in/*")

  output:
  tuple val(smp), path("${smp}*.fq.gz")

  script:
  if(params.se)
  """
  fastp -q 20 -u 50 -n 5 -6 -w $params.thread \
        -i in/${smp}.fq.gz -o ${smp}.fq.gz
  """
  else
  """
  fastp -q 20 -u 50 -n 5 -6 -w $params.thread \
        -i in/${smp}_1.fq.gz -I in/${smp}_2.fq.gz \
        -o ${smp}_1.fq.gz -O ${smp}_2.fq.gz
  """
}

