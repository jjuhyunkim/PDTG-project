#!/bin/sh

# ref : https://github.com/jonassibbesen/vgrna-project-paper/blob/main/scripts/bash/map_reads/vg/generate_gcsa.sh
module load samtools

prefix=$1
wd=$2
prefix_output=$3
mpmapMode=$4
threads=$5
rnaSeqFastq1=$6
rnaSeqFastq2=$7


if [ $mpmapMode == "paired" ]; then
	extra="-f $rnaSeqFastq1 -f $rnaSeqFastq2"
elif [ $mpmapMode == "single" ]; then
	extra="-l long -f $rnaSeqFastq1"
else
	exit
fi

# vg index -g ${prefix}_mod_prune.gcsa -k 16 ${prefix}_mod_prune.vg

RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'
YELLOW='\e[33m'
CYAN='\e[36m'

echo -e "${RED} vg version : \n`vg version`"

if [ ! -f ${wd}/03.pantranscriptome/distindexing.done ]; then
	cmd="vg index -j ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.dist \
		${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg && \
		touch ${wd}/03.pantranscriptome/distindexing.done"
	echo $cmd
	eval $cmd
fi

mkdir -p 04.multimapping
if [ ! -f ${wd}/04.multimapping/mpmap.done ]; then
	cmd="vg mpmap -t ${threads} \
		-n rna $extra \
		-x ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg \
		-g ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.gcsa \
		-d ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.dist \
		> ${wd}/04.multimapping/${prefix}.$prefix_output.aligned.gamp && touch ${wd}/04.multimapping/${prefix}.$prefix_output.mpmap.done"
	echo -e "${CYAN}CMD: $cmd ${RESET}\n"
	eval $cmd
fi

#if [ ! -f ${wd}/04.multimapping/gamp2bam.done ]; then
#	echo -e "${CYAN}CMD :vg paths -L -x ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg | \ \n \
#		grep $refSample  > ${wd}/04.multimapping/reference_paths.txt &&  \n \
#		vg surject -S -A -b -m -F ${wd}/04.multimapping/reference_paths.txt \ \n \
#		-x ${prefix}.xg ${prefix}.aligned.gamp > ${wd}/04.multimapping/${prefix}.aligned.bam &&\ \n \
#	       	samtools sort -O BAM -@${SLURM_CPUS_PER_TASK} ${wd}/04.multimapping/${prefix}.aligned.bam \ \n \
#		> ${wd}/04.multimapping/${prefix}.aligned.sorted.bam && \n
#		samtools index ${wd}/04.multimapping/${prefix}.aligned.sorted.bam && touch ${wd}/04.multimapping/gamp2bam.done${RESET}\n"
#	vg paths -L -x ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg | grep $refSample  \
#		> ${wd}/04.multimapping/reference_paths.txt &&
#	vg surject -S -A -b -m -F ${wd}/04.multimapping/reference_paths.txt \
#		-x ${prefix}.xg ${prefix}.aligned.gamp > ${wd}/04.multimapping/${prefix}.aligned.bam &&
#	samtools sort -O BAM -@${SLURM_CPUS_PER_TASK} ${wd}/04.multimapping/${prefix}.aligned.bam > ${wd}/04.multimapping/${prefix}.aligned.sorted.bam &&
#	samtools index ${wd}/04.multimapping/${prefix}.aligned.sorted.bam && touch ${wd}/04.multimapping/gamp2bam.done
#fi
