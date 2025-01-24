#! /bin/bash

# ARGUMENTS
ref=`realpath $1`
vcf=`realpath $2`
gtf=`realpath $3`
graph_prefix=$4
sample_prefix=$5
mainDir=`realpath $6`


if [[ "$#" -eq 7 ]]; then
    mpmapMode="single"
    rnaSeqFastq1=`realpath $7`
elif [[ "$#" -eq 8 ]]; then
    mpmapMode="paired"
    rnaSeqFastq1=`realpath $7`
    rnaSeqFastq2=`realpath $8`
else
    exit
fi

echo -e "ref : $ref"
echo -e "vcf : $vcf"
echo -e "gtf : $gtf"
echo -e "graph_prefix : $graph_prefix"
echo -e "sample_prefix : $sample_prefix"
echo -e "mainDir : $mainDir"
echo -e "RNA read(s) : $rnaSeqFastq1 $rnaSeqFastq2"
mambaEnv="diploid_transcriptome"

source /data/kimj75/miniforge3/bin/activate $mambaEnv
PIPELINE="/data/Phillippy/projects/HG002_Masseq/PDTG-project/scripts/haplotype-transcript"
schedular="/data/Phillippy/projects/HG002_Masseq/PDTG-project/scripts/schedular"


# RUN
threads=80
mkdir -p $mainDir/03.pantranscriptome
if [ ! -f $mainDir/03.pantranscriptome/autoindex.done ]; then
	if [ ! -f ${mainDir}/step1.autoindex.sbatch ]; then
		CMD1="sh ${schedular}/_submit_largemem.sh $threads 1200G ${graph_prefix}_autoindex ${PIPELINE}/07.autoindex.usingVCF.sh \
			\"$ref $vcf $gtf $graph_prefix $mainDir $threads\" \
	       		> ${mainDir}/step1.autoindex.sbatch"
		eval $CMD1
		echo $CMD1
	fi
fi

# check if the autoindex step completed sucessfully
sbatch --wrap="rm ${mainDir}/step1.autoindex.sbatch" --dependency=afternotok:$(sed '2!d' ${mainDir}/step1.autoindex.sbatch)



mkdir -p $mainDir/04.multimapping
if [ ! -f  $mainDir/04.multimapping/${sample_prefix}_mpmap.done ]; then
        CMD2="sh ${schedular}/_submit_multinode.sh 600 200G ${sample_prefix}_vg_mpmap ${PIPELINE}/03.vg_mpmap.autoindex.sh  \
                \"${graph_prefix} ${sample_prefix} ${mainDir} ${mpmapMode} ${rnaSeqFastq1} ${rnaSeqFastq2}\" \
		--dependency=afterok:$(sed '2!d' ${mainDir}/step1.autoindex.sbatch) \
                > ${mainDir}/${sample_prefix}.step2.mpmap.sbatch"
	eval $CMD2
	echo $CMD2
fi

# 04. quantification of haplotype-specific transcriptome
mkdir -p $mainDir/05.quantification
if [ ! -f "${mainDir}/05.quantification/${sample_prefix}_rpvg.done" ]; then
        CMD3="sh ${schedular}/_submit_norm.sh 10 50G ${sample_prefix}_rpvg ${PIPELINE}/04.rpvg.autoindex.sh \
                \"${mainDir} ${graph_prefix} ${sample_prefix} ${mpmapMode}\" \
		--dependency=afterok:$(sed '2!d' ${mainDir}/${sample_prefix}.step2.mpmap.sbatch) \
                > ${mainDir}/${sample_prefix}.step4.rpvg.sbatch"
	eval $CMD3
	echo $CMD3
fi

conda deactivate
