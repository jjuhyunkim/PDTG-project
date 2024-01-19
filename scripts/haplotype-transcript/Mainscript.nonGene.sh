#!/bin/bash

wd=$1
prefix=$2
gtf=$3
seqFile=$4
refSample=$5
rnaSeqFastq=$6

pipeline="/data/Phillippy/projects/HG002_Masseq/PDTG-project/scripts/haplotype-transcript"
RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'
YELLOW='\e[33m'
CYAN='\e[36m'


# --dependency=afterok:`sed '2!d' ${wd}/step1.construct.diploid_graph.sbatch` \

# 01. construct diploid graph reference 
if [ ! -f "${wd}/02.minigraph-cactus/construct_diploidGraph.done" ] ; then
	echo -e "${YELLOW}step1 : construct diploid graph reference${RESET}\n"
	echo -e "${CYAN}CMD : sh ~/code/_submit_norm.sh 20 100G const_genme \n\
                ${pipeline}/00.construct_diploidGraph.minigraph.v2.sh ${wd} ${seqFile} ${prefix} ${refSample} > ${wd}/step1.construct.diploid_graph.sbatch${RESET}\n"
	sh ~/code/_submit_norm.sh 20 100G const_genme \
		${pipeline}/00.construct_diploidGraph.minigraph.sh "${wd} ${seqFile} ${prefix} ${refSample}" > ${wd}/step1.construct.diploid_graph.sbatch
fi
# 02. construce splicing graph reference 
if [ ! -f "${wd}/03.pantranscriptome/xgGenerate.done" ]; then
	echo -e "${YELLOW}step2 : construct splicing graph reference${RESET}\n"
	echo -e "${CYAN}sh ~/code/_submit_norm.sh 10 10G const_splicing ${pipeline}/01.construct_splicedGraph_rmNonGene.sh  \ \n \
                ${wd} ${gtf} ${prefix} \ \n \
               > ${wd}/step2.construct.splicing_graph.sbatch${RESET}\n"
	sh ~/code/_submit_norm.sh 10 10G const_splicing ${pipeline}/01.construct_splicedGraph_rmNonGene.sh \
		"${wd} ${gtf} ${preqfix}" \
	       > ${wd}/step2.construct.splicing_graph.sbatch
fi

# 03. pan-transcriptome graph indexing
if [ ! -f "${wd}/03.pantranscriptome/gcsaIndexing.done" ]; then
        echo -e "${YELLOW}step3 : GSCA indexing${RESET}\n"
        echo -e "${CYAN}CMD : sh ~/code/00.code_management/_submit_largemem.sh 60 700G gcsa_indexing ${pipeline}/02.gcsa_indexing.sh \ \n \
                "${prefix} ${wd} ${rnaSeqFastq} $refSample" \ \n\
                --dependency=afterok:`sed '2!d' ${wd}/step2.construct.splicing_graph.sbatch` \ \n \
                > ${wd}/step3.mpmap.sbatch${RESET}"
        sh ~/code/00.code_management/_submit_largemem.sh 60 900G gcsa_indexing ${pipeline}/02.gcsa_indexing.sh \
                "${prefix} ${wd} ${rnaSeqFastq} $refSample" \
                --dependency=afterok:`sed '2!d' ${wd}/step2.construct.splicing_graph.sbatch` \
                > ${wd}/step3.gcsa_indexing.sbatch
fi

# 03. multi-mapping on splicing graph
if [ ! -f "${wd}/04.multimapping/gamp2bam.done" ]; then
	echo -e "${YELLOW}step4 : multi-path mapping with vg mpmap${RESET}\n"
	echo -e "${CYAN}CMD : sh ~/code/_submit_norm.sh 100 50G vg_mpmap ${pipeline}/03.vg_mpmap.sh \ \n \
                "${prefix} ${wd} ${rnaSeqFastq} $refSample" \ \n\
                --dependency=afterok:`sed '2!d' ${wd}/step3.gcsa_indexing.sbatch` \ \n \
                > ${wd}/step3.mpmap.sbatch${RESET}"
	sh ~/code/_submit_norm.sh 100 50G vg_mpmap ${pipeline}/03.vg_mpmap.sh \
		"${prefix} ${wd} ${rnaSeqFastq} $refSample" \
		--dependency=afterok:`sed '2!d' ${wd}/step3.gcsa_indexing.sbatch` \
		> ${wd}/step4.mpmap.sbatch
fi
# 04. quantification of haplotype-specific transcriptome
if [ ! -f "${wd}/05.quantification/rpvg.done" ]; then 
	echo -e "${YELLOW}step5 : quantification of haplotype-specific transcriptome${RESET}\n"
	echo -e "${CYAN}CMD :sh ~/code/_submit_norm.sh 10 20G rpvg ${pipeline}/04.rpvg.sh \ \n \
                ${wd} ${prefix} \ \n \
                --dependency=afterok:`sed '2!d' ${wd}/step4.mpmap.sbatch` \ \n \
                > ${wd}/step4.rpvg.sbatch${RESET}\n"
	sh ~/code/_submit_norm.sh 10 20G rpvg ${pipeline}/04.rpvg.sh \
		"${wd} ${prefix}" \
		--dependency=afterok:`sed '2!d' ${wd}/step4.mpmap.sbatch` \
		> ${wd}/step4.rpvg.sbatch
fi
