#!/bin/sh

wd=$1
prefix=$2
mpmapMode=$3

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


mkdir -p 05.quantification

cmd="${rpvg} -t $SLURM_CPUS_PER_TASK \
	--graph ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg \
	--paths ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.gbwt \
	--alignments ${wd}/04.multimapping/${prefix}.aligned.gamp \
	--output-prefix ${wd}/05.quantification/${prefix}.rpvg \
	--path-info ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.txt \
	$extra \
	--inference-model haplotype-transcripts && touch ${wd}/05.quantification/rpvg.done"
echo $cmd
eval $cmd
