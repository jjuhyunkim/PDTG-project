#!/bin/sh

wd=$1
prefix=$2

RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'
YELLOW='\e[33m'
CYAN='\e[36m'

rpvg="/data/kimj75/program/rpvg-v1.0_linux/bin/rpvg"

echo -e "${CYAN}CMD:${rpvg} --graph ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg \
        --paths ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.gbwt \
        --alignments ${wd}/04.multimapping/${prefix}.aligned.gamp \
        --output-prefix ${wd}/05.quantification/${prefix}.rpvg \
        --path-info ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.txt \
        --single-end --long-reads \
        --inference-model haplotype-transcripts && touch ${wd}/05.quantification/rpvg.done${RESET}\n"


mkdir -p 05.quantification

${rpvg} --graph ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg \
	--paths ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.gbwt \
	--alignments ${wd}/04.multimapping/${prefix}.aligned.gamp \
	--output-prefix ${wd}/05.quantification/${prefix}.rpvg \
	--path-info ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.txt \
	--single-end --long-reads \
	--inference-model haplotype-transcripts && touch ${wd}/05.quantification/rpvg.done
