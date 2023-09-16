#! /bin/bash

ref=$1
gtf=$2
inputRead=$3
refName=$4 #chm13 or hg38
output_prefix=$5

source /data/kimj75/anaconda3/bin/activate
pipeline='/data/Phillippy/projects/HG002_Masseq/PDTG-project/scripts/isoseq-analysis'

if [ ! -f pbmm2.done ] ; then
conda activate pacbioRNA
echo -e "sh ~/code/_submit_norm.sh 60 100G pbmm2_${output_prefix} ${pipeline}/pbmm2.sh \
        "${ref} ${inputRead} ${output_prefix}" > step1.pbmm2.sbatch"

sh ~/code/_submit_norm.sh 60 100G pbmm2_${output_prefix} ${pipeline}/pbmm2.sh \
	"${ref} ${inputRead} ${output_prefix}" > step1.pbmm2.sbatch
conda deactivate
fi 

if [ ! -f isoquant.done ]; then
conda activate isoquant
echo -e "sh ~/code/_submit_norm.sh 70 150G isoquant_${output_prefix} ${pipeline}/isoquant.sh \
        "${ref} ${gtf} ${output_prefix}.pbmm2.bam ${output_prefix}" \
        --dependency=afterok:`sed '2!d' step1.pbmm2.sbatch` > step2.isoquant.sbatch"

sh ~/code/_submit_norm.sh 70 150G isoquant_${output_prefix} ${pipeline}/isoquant.sh \
	"${ref} ${gtf} ${output_prefix}.pbmm2.bam ${output_prefix}" \
	--dependency=afterok:`sed '2!d' step1.pbmm2.sbatch` > step2.isoquant.sbatch
conda deactivate
fi

if [ ! -f squanti3.done ]; then
conda activate SQANTI3.env
echo -e "sh ~/code/_submit_norm.sh 50 60G squanti3_${prefix} ${pipeline}/sqanti3.${refName}.sh \
        "${ref} ${gtf} ${output_prefix}.isoquant/OUT/OUT.transcript_models.gtf . ${prefix}_squanti3" \
        --dependency=afterok:`sed '2!d' step2.isoquant.sbatch` > step3.isoquant.sbatch"

sh ~/code/_submit_norm.sh 50 60G squanti3_${prefix} ${pipeline}/sqanti3.${refName}.sh \
	"${ref} ${gtf} ${output_prefix}.isoquant/OUT/OUT.transcript_models.gtf . ${prefix}_squanti3" \
	--dependency=afterok:`sed '2!d' step2.isoquant.sbatch` > step3.isoquant.sbatch
conda deactivate
fi
