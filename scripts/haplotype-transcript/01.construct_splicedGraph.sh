#!/bin/bash
wd=$1
gtf=$2
prefix=$3

# extract sequence name from seqFile list 
#[[ -f ${wd}/seqList ]] && rm ${wd}/seqList
#for seqFile in `ls ${wd}/01.fastaFiles/*.seqFile`
#do chr=`basename $seqFile .seqFile`
#	echo $chr >> seqList
#done

RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'
YELLOW='\e[33m'
CYAN='\e[36m'


[[ -f ${wd}/seqList ]] && rm ${wd}/seqList
for seqFile in `ls ${wd}/01.fastaFiles/*.seqFile`
do chr=`basename $seqFile .seqFile`
        echo $chr >> seqList
done


mkdir -p ${wd}/03.pantranscriptome
# Converting graph from GBZ to pg and extract haplotype from GBZ file
echo -e "${YELLOW}Step1: construct pantranscriptome graph genome by each Chromosome${RESET}\n"
for chr in `cat ${wd}/seqList`
do echo $chr
	if [ ! -f ${wd}/03.pantranscriptome/${chr}.spliced_graph.done ]; then
		cmd="fgrep -w ${chr} ${gtf} > ${wd}/03.pantranscriptome/${chr}.gtf"
		echo -e $cmd
		eval $cmd

		cmd="vg rna -p --threads $SLURM_CPUS_PER_TASK \
			--transcripts ${wd}/03.pantranscriptome/${chr}.gtf \
			--gbz-format \
			--write-gbwt ${wd}/03.pantranscriptome/${chr}.pantranscriptome.gbwt \
			--write-info ${wd}/03.pantranscriptome/${chr}.pantranscriptome.txt \
			-f ${wd}/03.pantranscriptome/${chr}.pantranscriptome.fa \
			${wd}/02.minigraph-cactus/${prefix}.${chr}.gbz \
			--gbwt-bidirectional \
			> ${wd}/03.pantranscriptome/${chr}.spliced_graph.pg && touch ${wd}/03.pantranscriptome/${chr}.spliced_graph.done"
		echo -e $cmd
		eval $cmd
	fi
done
echo -e "${GREEN}Step1 done${RESET}\n"


### STEP2 : ID SPACE JOIN ###
splicingDoneFile=$(ls ${wd}/03.pantranscriptome/*.spliced_graph.done | wc -l)
TotalCount=$(wc -l ${wd}/seqList | cut -d ' ' -f 1 )

until [ ${splicingDoneFile} -eq ${TotalCount} ];
do
        splicingDoneFile=$(ls ${wd}/03.pantranscriptome/*.spliced_graph.done | wc -l)
	echo -e "${splicingDoneFile} / ${TotalCount}"
        echo -e "${RED}Wait for completing all chromosome${RESET}\n"
        sleep 30
done

# Join graphs
echo -e "${YELLOW}Step2: joining the id space between pg graphs of chromosome${RESET}\n"
if [ ! -f ${wd}/03.pantranscriptome/id_join.done ]; then

	for chr in `cat ${wd}/seqList`; do echo ${chr}; vg stats -z -l -r ${wd}/03.pantranscriptome/${chr}.spliced_graph.pg; done
	cmd="vg ids -j -m ${wd}/03.pantranscriptome/mapping \
		$(for chr in `cat ${wd}/seqList`; do echo ${wd}/03.pantranscriptome/${chr}.spliced_graph.pg;done) && touch ${wd}/03.pantranscriptome/id_join.done"
	echo -e $cmd
	eval $cmd
	cp ${wd}/03.pantranscriptome/mapping ${wd}/03.pantranscriptome/mapping.backup 
	for chr in `cat ${wd}/seqList`; do echo ${chr}; vg stats -z -l -r ${wd}/03.pantranscriptome/${chr}.spliced_graph.pg; done
fi
echo -e "${GREEN}Step2 done${RESET}\n"

# indexing splicing graph
echo -e "${YELLOW}Step3: merge the all pg graphs${RESET}\n"
if [ ! -f ${wd}/03.pantranscriptome/mergeXG.done ] ; then
	cmd="vg index -p -x ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.xg \
		$(for chr in `cat ${wd}/seqList`; do echo ${wd}/03.pantranscriptome/${chr}.spliced_graph.pg;done) && \
		touch ${wd}/03.pantranscriptome/mergeXG.done"
	echo $cmd
	eval $cmd
fi
echo -e "${GREEN}Step2 done${RESET}\n"

# construct pantranscriptome
cmd="vg gbwt -p \
	--output ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.gbwt \
	-f -m $(for chr in `cat ${wd}/seqList`; do echo ${wd}/03.pantranscriptome/${chr}.pantranscriptome.gbwt;done)"
echo $cmd
eval $cmd

cmd="cat $(for chr in `cat ${wd}/seqList`; do echo ${wd}/03.pantranscriptome/${chr}.pantranscriptome.txt;done) | grep -v Name | sed -e "1i Name\tLength\tTranscripts\tHaplotypes" > ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.txt"
echo $cmd
eval $cmd

cmd="cat $(for chr in `cat ${wd}/seqList`; do echo ${wd}/03.pantranscriptome/${chr}.pantranscriptome.fa;done) > ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.fa"
echo $cmd
eval $cmd

cmd="sed -i 's/CHM13#0#chr20,CHM13#0#chr20/CHM13#0#chr20,CHM13#1#chr20/g' ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.txt"
echo $cmd
eval $cmd

# generate gbwt.ri index
cmd="vg gbwt -r ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.gbwt.ri ${wd}/03.pantranscriptome/${prefix}.pantranscriptome.gbwt && touch ${wd}/03.pantranscriptome/xgGenerate.done"
echo $cmd
eval $cmd

