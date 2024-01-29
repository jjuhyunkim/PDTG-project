#! /bin/bash

refFasta=$1
refGTF=$2
longReadGTF=$3
outDir=$4
outPrefix=$5
refName=$6

filterMode='rules'

sqanti_bed_dir="/data/Phillippy/projects/HG002_Masseq/PDTG-project/scripts/isoseq-analysis/sqanti3_bed"

cDNA_cupcakeFolder="/data/kimj75/program/cDNA_Cupcake"
tss=$sqanti_bed_dir"/rnawg_cerberus_tss."${refName}".bed"
tes=$sqanti_bed_dir"/rnawg_cerberus_tes."${refName}".bed"
polya=$sqanti_bed_dir"/squanti3/human_polyA_motif.txt"


## dependencies ## 
sqantiDir="/data/kimj75/program/SQANTI3-5.1.2"


export PYTHONPATH=$PYTHONPATH:${cDNA_cupcakeFolder}/sequence/
export PYTHONPATH=$PYTHONPATH:${cDNA_cupcakeFolder}/rarefraction/

awk '$7 == "+" || $7 == "-" {print $0}' ${longReadGTF} | awk '$3 == "transcript" || $3 == "exon" { print $0}' > ${outDir}/longReadGTF.gtf
awk '$7 == "+" || $7 == "-" {print $0}' ${refGTF} | awk '$3 == "transcript" || $3 == "exon" { print $0}' > ${outDir}/refGTF.gtf

# 01 . QC
if [ ! -f  ${outDir}/sqanti3.qc.done ]; then
echo -e "python ${sqantiDir}/sqanti3_qc.py ${outDir}/longReadGTF.gtf ${outDir}/refGTF.gtf ${refFasta} \
        -o ${outPrefix} -d ${outDir} \
        --CAGE_peak ${tss} --polyA_motif_list ${polya} --polyA_peak ${tes} \
        --cpus ${SLURM_CPUS_PER_TASK} --isoAnnotLite && touch ${outDir}/sqanti3.qc.done\n"

python ${sqantiDir}/sqanti3_qc.py ${outDir}/longReadGTF.gtf  ${outDir}/refGTF.gtf ${refFasta} \
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
    	    	--refGTF ${outDir}/refGTF.gtf \
	    	--refClassif ${outDir}/${outPrefix}_classification.txt \
        	-o ${outPrefix} -d ${outDir} && touch ${outDir}/sqanti3.rescue.done\n"

		python ${sqantiDir}/sqanti3_rescue.py ${filterMode} ${outDir}/${outPrefix}_RulesFilter_result_classification.txt \
			--isoforms ${outDir}/${outPrefix}_corrected.fasta \
			--gtf ${outDir}/${outPrefix}.filtered.gtf \
			--refGTF ${outDir}/refGTF.gtf \
			-f ${refFasta} \
			--refClassif ${outDir}/${outPrefix}_classification.txt \
			-j ${sqantiDir}/utilities/filter/filter_default.json \
			-o ${outPrefix} -d ${outDir} && touch ${outDir}/sqanti3.rescue.done
	else
		python ${sqantiDir}/sqanti3_rescue.py ${filterMode} \
                        --isoforms ${outDir}/${outPrefix}_corrected.fasta \
                        --gtf ${outDir}/${outPrefix}.filtered.gtf \
                        --refGTF ${outDir}/refGTF.gtf \
			-f ${refFasta} \
                        --refClassif ${outDir}/${outPrefix}_classification.txt \
                        -o ${outPrefix} -d ${outDir} \
			${outDir}/${outPrefix}_RulesFilter_result_classification.txt && touch ${outDir}/sqanti3.rescue.done
	fi
fi


# 04. make table 
if [ ! -f ${outDir}/mkTable.done ]; then
	awk '$3 == "transcript" {print $0}' ${outDir}/${outPrefix}_rescued.gtf | sed -e 's/.*transcript_id "//' | sed -e 's/";.*//' > ${outDir}/${outPrefix}.rescued.gtf.transcripts
	cat <(head -1 ${outDir}/${outPrefix}_classification.txt) <(fgrep -f <(fgrep -f ${outDir}/${outPrefix}.rescued.gtf.transcripts <(cut -f 1-6 ${outDir}/${outPrefix}_classification.txt) ) ${outDir}/${outPrefix}_classification.txt) > ${outDir}/${outPrefix}_rescued_classification.txt && touch ${outDir}/mkTable.done
fi
