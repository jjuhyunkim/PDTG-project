#! /bin/bash
set -x 
# ARGUMENTS
ref=$1
vcf=$2
gtf=$3
prefix=$4
wd=$5
threads=$6

tmp=/vf/users/Phillippy/projects/subependymoma/02.processed_data/merge2sample/longRNA/graphTranscript/tmp

ulimit -u 10240 -n 16384

##### RUN ##### 
# check index for reference fasta file
if [ ! -f $ref.fai ]; then 
module load samtools
samtools faidx $ref
fi

# autoindex
autoindex_cmd="vg autoindex \
	--threads $threads \
	--tmp-dir $tmp
	--workflow mpmap \
	--workflow rpvg \
	--prefix $wd/03.pantranscriptome/$prefix \
	--ref-fasta $ref \
	--vcf $vcf \
	--tx-gff $gtf && touch $wd/03.pantranscriptome/autoindex.done" 
echo $autoindex_cmd
eval $autoindex_cmd
