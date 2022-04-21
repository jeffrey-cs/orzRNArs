#!/usr/env/bin nextflow

params.readlen     = 150
params.ref         = false  //gff file
params.thread      = 4
params.subdir      = 'transcript'
params.savemode    = 'link'
params.overwrite   = true

thread = params.thread > 16 ? 16 : params.thread


process StringtieE{
  tag {smp}

  errorStrategy 'finish'
  cpus thread

  publishDir "${params.outdir}/${params.subdir}/${smp}",
    mode: params.savemode,
    overwrite: params.overwrite

  input:
  tuple val(smp), path("${smp}.bam")

  output:
  tuple val(smp), path("${smp}.exp"), path("${smp}.gtf")

  script:
  """
  stringtie -e -G $params.ref -p $thread \
    -A ${smp}.exp -o ${smp}.gtf \
    ${smp}.bam
  """
}

process MergeStringtie{
  tag "Merging"

  errorStrategy 'finish'
  cpus 1

  publishDir "${params.outdir}/${params.subdir}/",
    mode: params.savemode,
    overwrite: params.overwrite

  input:
  path("*")

  output:
  path("Gene.*.tsv")
  path("Transcript.*.tsv")

  script:
  """
  ls *.gtf | tr " " "\\n" | awk -F "." '{print \$1"\\t"\$0}' > smp.list
  prepDE.py -i smp.list -g gene.tmp -t trans.tmp -l $params.readlen
  sed 's/[,|]/\\t/g' gene.tmp | sed 's/gene_name/GeneID\\tGeneName/'> Gene.Count.tsv
  sed 's/[,|]/\\t/g' trans.tmp > Transcript.Count.tsv
  python ${projectDir}/bin/processExp.py
  """
}

