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

CMD="${rpvg} -t $SLURM_CPUS_PER_TASK \
	--graph ${wd}/03.pantranscriptome/${graph_prefix}.spliced.xg \
	--paths ${wd}/03.pantranscriptome/${graph_prefix}.haplotx.gbwt \
	--alignments ${wd}/04.multimapping/${sample_prefix}.aligned.gamp \
	--output-prefix ${wd}/05.quantification/${sammple_prefix}.rpvg \
	--path-info ${wd}/03.pantranscriptome/${graph_prefix}.txorigin.txt \
	$extra \
	--inference-model haplotype-transcripts && touch ${wd}/05.quantification/${sammple_prefix}_rpvg.done"
echo $CMD
eval $CMD
