#!/bin/sh

wd=$1
graph_prefix=$2
sample_prefix=$3
mpmapMode=$4

RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'
YELLOW='\e[33m'
CYAN='\e[36m'

rpvg="/data/kimj75/program/rpvg-v1.0_linux/bin/rpvg"


if [[ "$mpmapMode" == "paired" ]]; then
        extra=""
elif [[ "$mpmapMode" == "single" ]]; then
        extra="--single-end --long-reads"
else
        exit
fi

${rpvg} -t $SLURM_CPUS_PER_TASK \
	--graph ${wd}/03.pantranscriptome/${graph_prefix}.pantranscriptome.xg \
	--paths ${wd}/03.pantranscriptome/${graph_prefix}.pantranscriptome.gbwt \
	--alignments ${wd}/04.multimapping/${sample_prefix}.aligned.gamp \
	--output-graph_prefix ${wd}/05.quantification/${sammple_prefix}.rpvg \
	--path-info ${wd}/03.pantranscriptome/${graph_prefix}.pantranscriptome.txt \
	$extra \
	--inference-model haplotype-transcripts && touch ${wd}/05.quantification/${sammple_prefix}_rpvg.done
