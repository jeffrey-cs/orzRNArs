#!/usr/bin/env nextflow

params.se      = false
params.ref     = false
params.subdir  = false
params.thread  = 4

process Bowtie2{
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
  if(!params.se)
  """
  bowtie2 --local -S /dev/null -p ${params.thread} \
    --mm -x ${params.ref} \
    -1 in/${smp}_1.fq.gz -2 in/${smp}_2.fq.gz \
    --un-conc-gz ${smp}_%.fq.gz \
    2> ${smp}.rRNA.log
  """
  else
  """
  bowtie2 --local -S /dev/null -p ${params.thread} \
    --mm -x ${params.ref} \
    -U in/${smp}.fq.gz --un-gz ${smp}.fq.gz \
    2> ${smp}.rRNA.log
  """
}

process Hisat2{
  tag {smp}

  errorStrategy 'finish'
  cpus params.thread

  publishDir "${params.outdir}/${params.subdir}/${smp}",
    mode: params.savemode,
    overwrite: params.overwrite

  afterScript "rm -rf *.sam"

  input:
  tuple val(smp), path("in/*")

  output:
  tuple val(smp), path("${smp}.bam"), path("${smp}.hisat2.log")

  script:
  if(!params.se)
  """
  hisat2 --threads $params.thread --mm \
    --new-summary --summary-file ${smp}.hisat2.log --dta \
    --no-mixed --no-discordant -S ${smp}.sam \
    -x ${params.ref} -1 in/${smp}_1.fq.gz -2 in/${smp}_2.fq.gz
  samtools view -bo - ${smp}.sam | \
  samtools sort --threads $params.thread --reference ${params.ref} \
    -o ${smp}.bam
  """
  else
  """
  hisat2 --threads $params.thread --mm \
    --new-summary --summary-file ${smp}.hisat2.log --dta \
    -S ${smp}.sam \
    -x ${params.ref} -U in/${smp}.fq.gz
  samtools view -bo - ${smp}.sam | \
  samtools sort --threads $params.thread --reference ${params.ref} \
    -o ${smp}.bam
  """
}

