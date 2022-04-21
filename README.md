# orzRNArs
refRNAseq pipeline - orz version

## Usage
nextflow main.nf --indir rawdata [--se]

*Note*
1. Use --se for single-end data
2. Fastq files in the rawdata folder should be named as samplename.fq.gz for single-end sequencing.data or samplename_{1,2}.fq.gz for pair-end sequencing data. Underlines or dots are allowed in the sample name.

## Configurations
Change the paths to the reference in the configuration file in ./configs.

## Current version
Minimal pipeline for generating expression matrix from raw fastq files.

Features:
1. Only for unstranded data now.
2. Data are filtered with fastp and rRNA removed with Bowtie2.
3. Reads are aligned using Hisat2 and gene expression estimated by StringTie using -E mode.

## TODO
1. Add more parameters. Eg. strandness.
2. Add sequencing assessment results.
3. Add more results. Eg. snp/indel/splice event assessment.
4. Use docker.
5. Extend the pipeline for RNAdenovo.
6. Fix bugs.

