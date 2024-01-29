#! /bin/bash

ref=$1
gtf=$2
inputRead=$3
refName=$4 #chm13 or hg38 #hg002
output_prefix=$5

echo -e "Ref : $ref\n"
echo -e "GTF : $gtf\n"
echo -e "inputRead : $inputRead\n"
echo -e "ref Name : $refName\n"
echo -e "output prefix : $output_prefix\n"




source /data/kimj75/anaconda3/bin/activate
pipeline='/data/Phillippy/projects/HG002_Masseq/PDTG-project/scripts/isoseq-analysis'

if [ ! -f pbmm2.done ] ; then
conda activate pacbioRNA
echo -e "sh $pipeline/_submit_norm.sh 60 100G pbmm2_${output_prefix} ${pipeline}/pbmm2.sh \
        "${ref} ${inputRead} ${output_prefix}" > step1.pbmm2.sbatch"

sh $pipeline/_submit_norm.sh 60 100G pbmm2_${output_prefix} ${pipeline}/pbmm2.sh \
	"${ref} ${inputRead} ${output_prefix}" > step1.pbmm2.sbatch
conda deactivate
fi 

if [ ! -f isoquant.done ]; then
conda activate isoquant
echo -e "sh $pipeline/_submit_norm.sh 50 60G isoquant_${output_prefix} ${pipeline}/isoquant.sh \
        "${ref} ${gtf} ${output_prefix}.pbmm2.bam ${output_prefix}" \
        --dependency=afterok:`sed '2!d' step1.pbmm2.sbatch` > step2.isoquant.sbatch"

sh $pipeline/_submit_norm.sh 50 60g isoquant_${output_prefix} ${pipeline}/isoquant.sh \
	"${ref} ${gtf} ${output_prefix}.pbmm2.bam ${output_prefix}" \
	--dependency=afterok:`sed '2!d' step1.pbmm2.sbatch` > step2.isoquant.sbatch
conda deactivate
fi

if [ ! -f squanti3.done ]; then
conda activate SQANTI3.env
mkdir -p squanti3_model
echo -e "sh $pipeline/_submit_norm.sh 50 60G squanti3_${prefix} ${pipeline}/sqanti3.${refName}.sh \
        "${ref} ${gtf} ${output_prefix}.isoquant/OUT/OUT.transcript_models.gtf squanti3_model ${output_prefix}_squanti3" \
        --dependency=afterok:`sed '2!d' step2.isoquant.sbatch` > step3.isoquant.sbatch"
sh $pipeline/_submit_norm.sh 50 60G squanti3_${prefix} ${pipeline}/sqanti3.${refName}.sh \
        "${ref} ${gtf} ${output_prefix}/OUT/OUT.transcript_models.gtf squanti3_model ${output_prefix}_squanti3" \
        --dependency=afterok:`sed '2!d' step2.isoquant.sbatch` > step3.isoquant.sbatch

mkdir -p squanti3_extended
echo -e "sh $pipeline/_submit_norm.sh 50 60G squanti3_${prefix} ${pipeline}/sqanti3.${refName}.sh \
        "${ref} ${gtf} ${output_prefix}.isoquant/OUT/OUT.extended_annotation.gtf squanti3_extended ${output_prefix}_squanti3" \
        --dependency=afterok:`sed '2!d' step2.isoquant.sbatch` > step3.isoquant.sbatch"
sh $pipeline/_submit_norm.sh 50 60G squanti3_${prefix} ${pipeline}/sqanti3.${refName}.sh \
	"${ref} ${gtf} ${output_prefix}/OUT/OUT.extended_annotation.gtf squanti3_extended ${output_prefix}_squanti3" \
	--dependency=afterok:`sed '2!d' step2.isoquant.sbatch` > step3.isoquant.sbatch
conda deactivate
fi
