#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

/*----------------- parameters -----------------*/

params.pid       = "TEST"

params.se        = false
params.readlen   = 150

params.noqc      = false
params.nofilter  = false
params.nofrrna   = false

params.indir     = false
params.outdir    = launchDir

params.thread    = 4
params.savemode  = 'link'
params.overwrite = true
params.help      = false

/*----------------- utilities ------------------*/

include {errLog; hlpLog} from "./modules/utils"
include {checkFile} from "./modules/utils"

include {FastQC; MultiQC} from "./modules/qc" \
  addParams(subdir:"01.QC")
include {Fastp} from "./modules/filter" \
  addParams(subdir:"02.Filter")
include {Bowtie2} from "./modules/aligner" \
  addParams(subdir:"03.rRNA", ref:params.ref.rrna)
include {Hisat2} from "./modules/aligner" \
  addParams(subdir:"04.Align", ref:params.ref.genome)
include {StringtieE;MergeStringtie} from "./modules/transcript" \
  addParams(subdir:"05.Expression", ref:params.ref.gff)

/*----------------- pipelines ------------------*/

workflow qcWfl {
  take: in4qc
  main: FastQC(in4qc) | collect | MultiQC
}

workflow filterWfl {
  take: in4filter
  main: Fastp(in4filter)
  emit: Fastp.out
}

workflow rRNAWfl{
  take: in4rrna
  main: Bowtie2(in4rrna)
  emit: Bowtie2.out
}

workflow alignWfl{
  take: in4align
  main: Hisat2(in4align)
  emit: Hisat2.out.map{it[0..1]}
}

workflow quantWfl{
  take: in4quant
  main:
    StringtieE(in4quant) | map{it[1..2]} | collect | MergeStringtie
}

/*------ Welcome to orzRNAseq. Good Luck! ------*/

usageInfo = ["Not Finished!"]
if(params.help) hlpLog(usageInfo)
if(!params.indir) errLog("--indir is required!")

workflow {
  if(!params.se){
    fqFile = channel.fromFilePairs("${params.indir}/*_{1,2}.fq.gz")
  } else {
    channel.fromPath("${params.indir}/*.fq.gz")
           .map{[it.baseName.minus(".fq"), it]}
           .set{fqFile}
  }

  if(!params.noqc) qcWfl(fqFile)

  params.nofilter ? 0 : filterWfl(fqFile)
  in4rrna = params.nofilter ? fqFile : filterWfl.out

  params.nofrrna ? 0 : rRNAWfl(in4rrna)
  in4align = params.nofrrna ? in4rrna : rRNAWfl.out

  alignWfl(in4align) | quantWfl
}


