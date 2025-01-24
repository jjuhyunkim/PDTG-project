#!/bin/sh

# ref : https://github.com/jonassibbesen/vgrna-project-paper/blob/main/scripts/bash/map_reads/vg/generate_gcsa.sh
module load samtools


prefix=$1
wd=$2
isoseq=$3
refSample=$4

# vg index -g ${prefix}_mod_prune.gcsa -k 16 ${prefix}_mod_prune.vg

RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'
YELLOW='\e[33m'
CYAN='\e[36m'

echo -e "${RED} vg version : \n`vg version`"
# GCSA indexing 
if [ ! -f ${wd}/03.pantranscriptome/gcsaIndexing.done ]; then
        cmd="cp ${wd}/03.pantranscriptome/mapping.backup ${wd}/03.pantranscriptome/mapping"
	echo $cmd
	eval $cmd

for chr in `cat ${wd}/seqList`
do
        if [ ! -f ${wd}/03.pantranscriptome/${chr}.spliced_graph_pruned.done ];then
        cmd="vg prune -p -t ${SLURM_CPUS_PER_TASK} \
                -r ${wd}/03.pantranscriptome/${chr}.spliced_graph.pg \
		-e 2 \
                > ${wd}/03.pantranscriptome/${chr}.spliced_graph_pruned.vg && touch ${wd}/03.pantranscriptome/${chr}.spliced_graph_pruned.done"
	echo $cmd
	eval $cmd

        fi
done


rm -rf ${wd}/tmpDir
mkdir -p ${wd}/tmpDir
tmpDir="${wd}/tmpDir"

cmd="vg index -p -t ${SLURM_CPUS_PER_TASK}\
        --temp-dir ${tmpDir} \
        -Z 20000 \
        -g ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.gcsa \
        $(for chr in `cat ${wd}/seqList`; do echo ${wd}/03.pantranscriptome/${chr}.spliced_graph_pruned.vg; done) && touch ${wd}/03.pantranscriptome/gcsaIndexing.done"
echo $cmd
eval $cmd

fi

