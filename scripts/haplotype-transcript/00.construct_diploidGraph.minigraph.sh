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
rm -rf ${wd}/01.fastaFiles/*
for sample in `cut -f 1 ${seqFile} | cat`
do 
	fasta=$(awk -v sample=$sample '$1 == sample {print $2} ' $seqFile)
	# indexing reference fasta
	if [ ! -f ${fasta}.fai ]; then
		echo -e "Start indexing using samtools faidx $fasta \n"
		samtools faidx ${fasta}
	fi

	fgrep ">" ${fasta} | cut -d' ' -f 1 | sed -e 's/>//' > ${wd}/01.fastaFiles/${sample}.chrList
	
	# Extracting fasta by chromosoem 
	for chr in `cat ${wd}/01.fastaFiles/${sample}.chrList` 
	do
		samtools faidx ${fasta} ${chr} > ${wd}/01.fastaFiles/${sample}.${chr}.fa
		echo -e "${sample}\t${wd}/01.fastaFiles/${sample}.${chr}.fa" >> ${wd}/01.fastaFiles/${chr}.seqFile 
	done
	touch ${wd}/01.fastaFiles/${sample}.seqFile.done
done
fi

if [ $(ls ${wd}/01.fastaFiles/*.seqFile.done | wc -l) = $(wc -l ${seqFile} ) ]; then
	touch ${wd}/seqFile.generator.done
fi

# graph construction
mkdir -p 02.minigraph-cactus

if [ -f ${wd}/seqFile.generator.done ] ; then
for i in `ls ./01.fastaFiles/*.seqFile`
do chr=`basename $i .seqFile`
	[ -d "${wd}/02.minigraph-cactus/js_${chr}" ] && rm -rf "${wd}/02.minigraph-cactus/js_${chr}" 
	echo -e "cactus-pangenome ${wd}/02.minigraph-cactus/js_${chr} ${wd}/01.fastaFiles/${chr}.seqFile \ \n \
                --outDir ${wd}/02.minigraph-cactus --outName ${prefix}.${chr} \ \n \
                --reference ${refSample} \ \n \
                --odgi --draw --viz --vcf --giraffe --gfa --gbz --chrom-vg && touch ${wd}/02.minigraph-cactus/construct_diploidGraph.done\n"
	cactus-pangenome ${wd}/02.minigraph-cactus/js_${chr} ${wd}/01.fastaFiles/${chr}.seqFile \
		--outDir ${wd}/02.minigraph-cactus --outName ${prefix}.${chr} \
		--reference ${refSample} \
		--odgi --draw --viz --vcf --giraffe --gfa --gbz && touch ${wd}/02.minigraph-cactus/construct_diploidGraph.done
done
fi
