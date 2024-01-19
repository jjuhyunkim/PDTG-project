#!/bin/sh

# ref : https://github.com/jonassibbesen/vgrna-project-paper/blob/main/scripts/bash/map_reads/vg/generate_gcsa.sh
module load samtools

graph_graph_prefix=$1
sample_graph_prefix=$2
wd=$3
mpmapMode=$4
rnaSeqFastq1=$5
rnaSeqFastq2=$6

if [ $mpmapMode == "paired" ]; then
	extra="-f $rnaSeqFastq1 -f $rnaSeqFastq2"
elif [ $mpmapMode == "single" ]; then
	extra="-l long -f $rnaSeqFastq1"
else
	exit
fi

if [ ! -f ${wd}/mpmap.done ]; then
	CMD="vg mpmap -t ${SLURM_CPUS_PER_TASK} \
		-n rna $extra \
		-x ${wd}/03.pantranscriptome/${graph_prefix}.pantranscriptome.xg \
		-g ${wd}/03.pantranscriptome/${graph_prefix}.pantranscriptome.gcsa \
		-d ${wd}/03.pantranscriptome/${graph_prefix}.pantranscriptome.dist \
		> ${wd}/04.multimapping/${sample_prefix}.aligned.gamp && touch ${wd}/04.multimapping/mpmap.done"
	echo $CMD
	eval $CMD
fi

