#!/bin/bash
set -e
ml fastp/0.23.2

thread=50 
fastq=$1 
prefix=$(basename $fastq .fastq.gz)
dir=$(realpath $(dirname $fastq))

fastp --thread $thread \
	--in1 $fastq \
	--html $dir/$prefix.html

