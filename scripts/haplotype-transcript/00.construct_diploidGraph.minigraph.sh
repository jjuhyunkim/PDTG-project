#!/bin/bash

module load cactus

wd=$1
seqFile=$2
prefix=$3
refSample=$4

module load samtools

# make fasta files by chromosome
mkdir -p ${wd}/01.fastaFiles

if [ ! -f "${wd}/seqFile.generator.done" ] ; then
rm ${wd}/01.fastaFiles/*
for sample in `cut -f 1 ${seqFile} | cat`
do 
	fasta=`grep -w ${sample} ${seqFile}| cut -f 2`
	samtools faidx ${fasta}
	fgrep ">" ${fasta} | cut -d' ' -f 1 | sed -e 's/>//' > ${wd}/01.fastaFiles/${sample}.chrList
	for chr in `cat ${wd}/01.fastaFiles/${sample}.chrList` 
	do
		echo "$sample $chr"	
		samtools faidx ${fasta} ${chr} > ${wd}/01.fastaFiles/${sample}.${chr}.fa
		echo -e "${sample}\t${wd}/01.fastaFiles/${sample}.${chr}.fa" >> ${wd}/01.fastaFiles/${chr}.seqFile
	done
done && touch ${wd}/seqFile.generator.done
fi

# graph construction
mkdir -p 02.minigraph-cactus

for i in `ls ./01.fastaFiles/*.seqFile`
do chr=`basename $i .seqFile`
	[ -d "${wd}/02.minigraph-cactus/js_${chr}" ] && rm -rf "${wd}/02.minigraph-cactus/js_${chr}" 
	cactus-pangenome ${wd}/02.minigraph-cactus/js_${chr} ${wd}/01.fastaFiles/${chr}.seqFile \
		--outDir ${wd}/02.minigraph-cactus --outName ${prefix}.${chr} \
		--reference ${refSample} \
		--vcf --giraffe --gfa --gbz && touch ${wd}/02.minigraph-cactus/construct_diploidGraph.done
done
