#!/bin/bash


wd=$1
prefix=$2
gtf=$3
seqFile=$4
refSample=$5
rnaSeqFastq1=$6
rnaSeqFastq2=$7


mambaEnv="diploid_transcriptome"
echo $#

if [[ "$#" -eq 6 ]]; then
    mpmapMode="single"
elif [[ "$#" -eq 7 ]]; then
    mpmapMode="paired"
else
    exit
fi

echo $mpmapMode
echo "wd : $wd"
echo "prefix : $prefix"
echo "gtf : $gtf"
echo "seqFile : $seqFile"
echo "resSample : $refSample"
echo "rnaSeqFastq : $rnaSeqFastq1 $rnaSeqFastq2"

pipeline="/data/Phillippy/projects/HG002_Masseq/PDTG-project/scripts/haplotype-transcript"
RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'
YELLOW='\e[33m'
CYAN='\e[36m'

# source /data/kimj75/miniforge3/bin/activate
# source /data/kimj75/miniforge3/etc/profile.d/mamba.sh

# mamba activate diploid_transcriptome


# 01. construct diploid graph reference 
if [ ! -f "${wd}/02.minigraph-cactus/construct_diploidGraph.done" ] ; then
	echo -e "${YELLOW}step1 : construct diploid graph reference${RESET}\n"
	thread="20"
	mem="100g"
	J="const_genme"

	cmd="sh ~/code/_submit_norm.sh $thread $mem $J ${pipeline}/00.construct_diploidGraph.minigraph.sh \
		\"${wd} ${seqFile} ${prefix} ${refSample}\" > ${wd}/step1.construct.diploid_graph.sbatch"
	echo $cmd && eval $cmd
fi
# 02. construce splicing graph reference 
if [ ! -f "${wd}/03.pantranscriptome/xgGenerate.done" ]; then
	echo -e "${YELLOW}step2 : construct splicing graph reference${RESET}\n"
	thread="10"
	mem="10g"
	J="const_splicing"
	jobID=$(tail -1 ${wd}/step1.construct.diploid_graph.sbatch)

	cmd="sh ~/code/_submit_norm.sh $thread $mem $J ${pipeline}/01.construct_splicedGraph.sh \
		\"${wd} ${gtf} ${prefix}\" \
	       --dependency=afterok:$jobID \
		> ${wd}/step2.construct.splicing_graph.sbatch"
	echo $cmd && eval $cmd
fi

# 03. pan-transcriptome graph indexing
if [ ! -f "${wd}/03.pantranscriptome/gcsaIndexing.done" ]; then
        echo -e "${YELLOW}step3 : GSCA indexing${RESET}\n"
	thread="60"
	mem="900G"
	J="gcsa_indexing"
	jobID=$(tail -1 ${wd}/step2.construct.splicing_graph.sbatch)

        cmd="sh ~/code/00.code_management/_submit_largemem.sh $thread $mem $J ${pipeline}/02.gcsa_indexing.sh \
		\"${prefix} ${wd} ${rnaSeqFastq} ${refSample}\" \
                --dependency=afterok:$jobID \
		> ${wd}/step3.gcsa_indexing.sbatch"
	echo $cmd && eval $cmd
fi

# 03. multi-mapping on splicing graph
if [ ! -f "${wd}/04.multimapping/gamp2bam.done" ]; then
	echo -e "${YELLOW}step4 : multi-path mapping with vg mpmap${RESET}\n"
	thread="100"
	mem="100G"
	J="vg_mpmap"
	jobID=$(tail -1 ${wd}/step3.gcsa_indexing.sbatch)

	cmd="sh ~/code/_submit_norm.sh $thread $mem $J ${pipeline}/03.vg_mpmap.sh \
		\"${prefix} ${wd} ${mpmapMode} ${rnaSeqFastq1} ${rnaSeqFastq2} 100\" \
		--dependency=afterok:$jobID \
		> ${wd}/step4.mpmap.sbatch"
	echo $cmd && eval $cmd
fi
# 04. quantification of haplotype-specific transcriptome
if [ ! -f "${wd}/05.quantification/rpvg.done" ]; then 
	echo -e "${YELLOW}step5 : quantification of haplotype-specific transcriptome${RESET}\n"
	thread="10"
	mem="20G"
	J="rpvg"
	jobID=$(tail -1 ${wd}/step4.mpmap.sbatch)
	
	cmd="sh ~/code/_submit_norm.sh $thread $mem $J ${pipeline}/04.rpvg.sh \
		\"${wd} ${prefix} ${mpmapMode}\" \
		--dependency=afterok:$jobID \
		> ${wd}/step4.rpvg.sbatch"
	echo $cmd && eval $cmd
fi

# mamba deactivate
