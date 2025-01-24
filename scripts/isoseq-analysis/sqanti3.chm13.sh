#! /bin/bash

refFasta=$1
refGTF=$2
longReadGTF=$3
outDir=$4
outPrefix=$5


source /data/kimj75/anaconda3/bin/activate

conda activate SQANTI3.env


filterMode='rules'

cDNA_cupcakeFolder="/data/kimj75/program/cDNA_Cupcake"
tss="/data/kimj75/00.Files/squanti3/rnawg_cerberus_tss.chm13.bed"
tes="/data/kimj75/00.Files/squanti3/rnawg_cerberus_tes.chm13.bed"
polya="/data/kimj75/00.Files/squanti3/human_polyA_motif.txt"


## dependencies ## 
sqantiDir="/data/kimj75/program/SQANTI3-5.1.2"

export PYTHONPATH=$PYTHONPATH:${cDNA_cupcakeFolder}/sequence/
export PYTHONPATH=$PYTHONPATH:${cDNA_cupcakeFolder}/rarefraction/

awk '$7 == "+" || $7 == "-" {print $0}' ${longReadGTF} | awk '$3 != "gene" {print $0}' > ${outDir}/longReadGTF.gtf
# awk '$7 == "+" || $7 == "-" {print $0}' ${longReadGTF} >${outDir}/longReadGTF.gtf 

# 01 . QC
if [ ! -f  ${outDir}/sqanti3.qc.done ]; then
echo -e "python ${sqantiDir}/sqanti3_qc.py ${outDir}/longReadGTF.gtf ${refGTF} ${refFasta} \
        -o ${outPrefix} -d ${outDir} \
	--CAGE_peak ${tss} --polyA_motif_list ${polya} --polyA_peak ${tes} \
        --cpus ${SLURM_CPUS_PER_TASK} --isoAnnotLite && touch ${outDir}/sqanti3.qc.done\n"

python ${sqantiDir}/sqanti3_qc.py ${outDir}/longReadGTF.gtf  ${refGTF} ${refFasta} \
	-o ${outPrefix} -d ${outDir} \
	--CAGE_peak ${tss} --polyA_motif_list ${polya} --polyA_peak ${tes} \
	--cpus ${SLURM_CPUS_PER_TASK} --isoAnnotLite && touch ${outDir}/sqanti3.qc.done
fi


# 02 . Filter
if [ ! -f ${outDir}/sqanti3.filter.done ]; then
echo -e "python ${sqantiDir}/sqanti3_filter.py ${filterMode} ${outDir}/${outPrefix}_classification.txt \
        -o ${outPrefix} -d ${outDir} \
        --gtf ${outDir}/${outPrefix}_corrected.gtf && touch ${outDir}/sqanti3.filter.done\n"

python ${sqantiDir}/sqanti3_filter.py ${filterMode} ${outDir}/${outPrefix}_classification.txt \
	-o ${outPrefix} -d ${outDir} \
	--gtf ${outDir}/${outPrefix}_corrected.gtf && touch ${outDir}/sqanti3.filter.done
fi

# 03 . Rescue
if [ ! -f ${outDir}/sqanti3.rescue.done ]; then
	if [ ${filterMode} == "rules" ] ; then
	echo -e "python ${sqantiDir}/sqanti3_rescue.py ${filterMode} \
        	--isoforms ${outDir}/${outPrefix}_corrected.fasta \
   	     	--gtf ${outDir}/${outPrefix}.filtered.gtf \
    	    	--refGTF ${refGTF} \
	    	--refClassif ${outDir}/${outPrefix}_classification.txt \
        	-o ${outPrefix} -d ${outDir} && touch ${outDir}/sqanti3.rescue.done\n"

		python ${sqantiDir}/sqanti3_rescue.py ${filterMode} ${outDir}/${outPrefix}_RulesFilter_result_classification.txt \
			--isoforms ${outDir}/${outPrefix}_corrected.fasta \
			--gtf ${outDir}/${outPrefix}.filtered.gtf \
			--refGTF ${refGTF} \
			-f ${refFasta} \
			--refClassif ${outDir}/${outPrefix}_classification.txt \
			-j ${sqantiDir}/utilities/filter/filter_default.json \
			-o ${outPrefix} -d ${outDir} && touch ${outDir}/sqanti3.rescue.done
	else
		python ${sqantiDir}/sqanti3_rescue.py ${filterMode} \
                        --isoforms ${outDir}/${outPrefix}_corrected.fasta \
                        --gtf ${outDir}/${outPrefix}.filtered.gtf \
                        --refGTF ${refGTF} \
			-f ${refFasta} \
                        --refClassif ${outDir}/${outPrefix}_classification.txt \
                        -o ${outPrefix} -d ${outDir} \
			${outDir}/${outPrefix}_RulesFilter_result_classification.txt && touch ${outDir}/sqanti3.rescue.done
	fi
fi


# 04. make table 
if [ ! -f ${outDir}/mkTable.done ]; then
awk '$3 == "transcript" {print $0}' ${outDir}/${outPrefix}_rescued.gtf | sed -e 's/.*transcript_id "//' | sed -e 's/";.*//' > ${outDir}/${outPrefix}.rescued.gtf.transcripts
fgrep -w -f ${outDir}/${outPrefix}.rescued.gtf.transcripts ${outDir}/${outPrefix}_classification.txt > ${outDir}/${outPrefix}_rescued_classification.txt && touch ${outDir}/mkTable.done
fi

conda deactivate
