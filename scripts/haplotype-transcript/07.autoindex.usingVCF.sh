#! /bin/bash

# ARGUMENTS
ref=$1
vcf=$2
gtf=$3
prefix=$4
wd=$5

threads=$SLURM_CPUS_PER_TASK

##### RUN ##### 
# check index for reference fasta file
if [ ! -f $ref.fai ]; then 
module load samtools
samtools faidx $ref
fi




# autoindex
autoindex_cmd="vg autoindex \
	--threads $threads \
	--workflow mpmap \
	--workflow rpvg \
	--prefix $wd/03.pantranscriptome/$prefix \
	--ref-fasta $ref \
	--vcf $vcf \
	--tx-gff $gtf && touch $wd/03.pantranscriptome/autoindex.done" 
echo $autoindex_cmd
eval $autoindex_cmd

