#! /bin/bash

# ARGUMENTS
ref=`realpath $1`
vcf=`realpath $2`
gtf=`realpath $3`
graph_prefix=$4
sample_prefix=$5
mainDir=`realpath $6`

rnaSeqFastq1=`realpath $7`
rnaSeqFastq2=`realpath $8`

mambaEnv="diploid_transcriptome"

if [[ "$#" -eq 7 ]]; then
    mpmapMode="single"
elif [[ "$#" -eq 8 ]]; then
    mpmapMode="paired"
else
    exit
fi
PIPELINE="/data/Phillippy/projects/HG002_Masseq/PDTG-project/scripts/haplotype-transcript"

# RUN
mkdir -p $mainDir/03.pantranscriptome 
if [ ! -f $mainDir/03.pantranscriptome/autoindex.done ]; then
	if [ ! -f ${mainDir}/step1.autoindex.sbatch ]; then
		CMD="sh ~/code/_submit_norm.sh 50 100G ${graph_prefix}_autoindex ${PIPELINE}/07.autoindex.usingVCF.sh \
			\"$ref $vcf $gtf $graph_prefix $mainDir\" \
	       		> ${mainDir}/step1.autoindex.sbatch"
		eval $CMD
		echo $CMD
	fi
fi

mkdir -p $mainDir/04.multimapping
if [ ! -f  $mainDir/04.multimapping/${sample_prefix}_mpmap.done ]; then
        CMD="sh ~/code/_submit_norm.sh 50 40G ${sample_prefix}_vg_mpmap ${PIPELINE}/03.vg_mpmap.autoindex.sh  \
                \"${graph_prefix} ${sample_prefix} ${mainDir} ${mpmapMode} ${rnaSeqFastq1} ${rnaSeqFastq2}\" \
		--dependency=afterok:$(sed '2!d' ${mainDir}/step1.autoindex.sbatch) \
                > ${mainDir}/${sample_prefix}.step2.mpmap.sbatch"
	eval $CMD
	echo $CMD
fi

# 04. quantification of haplotype-specific transcriptome
mkdir -p $mainDir/05.quantification
if [ ! -f "${mainDir}/05.quantification/${sample_prefix}_rpvg.done" ]; then
        CMD="sh ~/code/_submit_norm.sh 10 50G ${sample_prefix}_rpvg ${PIPELINE}/04.rpvg.autoindex.sh \
                \"${mainDir} ${graph_prefix} ${sample_prefix} ${mpmapMode}\" \
		--dependency=afterok:$(sed '2!d' ${mainDir}/${sample_prefix}.step2.mpmap.sbatch) \
                > ${mainDir}/${sample_prefix}.step4.rpvg.sbatch"
	eval $CMD
	echo $CMD
fi

