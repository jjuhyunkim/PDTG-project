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
	echo -e "${CYAN}CMD :cp ${wd}/03.pantranscriptome/mapping.backup ${wd}/03.pantranscriptome/mapping${RESET}\n"
	cp ${wd}/03.pantranscriptome/mapping.backup ${wd}/03.pantranscriptome/mapping
for chr in `cat ${wd}/seqList`
do
	if [ ! -f ${wd}/03.pantranscriptome/${chr}.spliced_graph_pruned.done ];then
	echo -e "${CYAN}CMD :vg prune -p -t ${SLURM_CPUS_PER_TASK} \ \n \
		-r \ 
                ${wd}/03.pantranscriptome/${chr}.spliced_graph.pg \
                > ${wd}/03.pantranscriptome/${chr}.spliced_graph_pruned.vg && touch ${wd}/03.pantranscriptome/${chr}.spliced_graph_pruned.done ${RESET}" 
	
	vg prune -p -t ${SLURM_CPUS_PER_TASK} \
		-r ${wd}/03.pantranscriptome/${chr}.spliced_graph.pg \
		> ${wd}/03.pantranscriptome/${chr}.spliced_graph_pruned.vg && touch ${wd}/03.pantranscriptome/${chr}.spliced_graph_pruned.done
	fi
done

mkdir -p /data/kimj75/tmp
echo -e "${CYAN}CMD :vg index -p -t ${SLURM_CPUS_PER_TASK} \ \n \ 
	--temp-dir /data/kimj75/tmp \ \n \
        -Z 4500 \ \n \
        -g ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.gcsa \ \n \
        $(for chr in `cat ${wd}/seqList`; do echo ${wd}/03.pantranscriptome/${chr}.spliced_graph_pruned.vg; done) && touch ${wd}/03.pantranscriptome/gcsaIndexing.done${RESET}"

vg index -p -t ${SLURM_CPUS_PER_TASK}\
	--temp-dir /data/kimj75/tmp \
	-Z 4500 \
	-g ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.gcsa \
	$(for chr in `cat ${wd}/seqList`; do echo ${wd}/03.pantranscriptome/${chr}.spliced_graph_pruned.vg; done) && touch ${wd}/03.pantranscriptome/gcsaIndexing.done
fi

if [ ! -f ${wd}/03.pantranscriptome/distindexing.done ]; then
	echo -e "${CYAN}CMD :vg index -j ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.dist \ \n \
		${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg && \ \n \
		touch ${wd}/03.pantranscriptome/distindexing.done${RESET}\n"
	vg index -j ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.dist \
		${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg && \
		touch ${wd}/03.pantranscriptome/distindexing.done
fi

mkdir -p 04.multimapping
if [ ! -f ${wd}/04.multimapping/mpmap.done ]; then
	echo -e "${CYAN}CMD :vg mpmap -t ${SLURM_CPUS_PER_TASK} \ \n \
                -n rna -l long \ \n \
                -x ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg \ \n \
                -g ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.gcsa \ \n \
                -d ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.dist \ \n \
                -f ${isoseq} > ${wd}/04.multimapping/${prefix}.aligned.gamp && touch ${wd}/04.multimapping/mpmap.done${RESET}\n"
	vg mpmap -t ${SLURM_CPUS_PER_TASK} \
		-n rna -l long \
		-x ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg \
		-g ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.gcsa \
		-d ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.dist \
		-f ${isoseq} > ${wd}/04.multimapping/${prefix}.aligned.gamp && touch ${wd}/04.multimapping/mpmap.done
fi

if [ ! -f ${wd}/04.multimapping/gamp2bam.done ]; then
	echo -e "${CYAN}CMD :vg paths -L -x ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg | \ \n \
		grep $refSample  > ${wd}/04.multimapping/reference_paths.txt &&  \n \
		vg surject -S -A -b -m -F ${wd}/04.multimapping/reference_paths.txt \ \n \
		-x ${prefix}.xg ${prefix}.aligned.gamp > ${wd}/04.multimapping/${prefix}.aligned.bam &&\ \n \
	       	samtools sort -O BAM -@${SLURM_CPUS_PER_TASK} ${wd}/04.multimapping/${prefix}.aligned.bam \ \n \
		> ${wd}/04.multimapping/${prefix}.aligned.sorted.bam && \n
		samtools index ${wd}/04.multimapping/${prefix}.aligned.sorted.bam && touch ${wd}/04.multimapping/gamp2bam.done${RESET}\n"
	vg paths -L -x ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg | grep $refSample  \
		> ${wd}/04.multimapping/reference_paths.txt &&
	vg surject -S -A -b -m -F ${wd}/04.multimapping/reference_paths.txt \
		-x ${prefix}.xg ${prefix}.aligned.gamp > ${wd}/04.multimapping/${prefix}.aligned.bam &&
	samtools sort -O BAM -@${SLURM_CPUS_PER_TASK} ${wd}/04.multimapping/${prefix}.aligned.bam > ${wd}/04.multimapping/${prefix}.aligned.sorted.bam &&
	samtools index ${wd}/04.multimapping/${prefix}.aligned.sorted.bam && touch ${wd}/04.multimapping/gamp2bam.done
fi
