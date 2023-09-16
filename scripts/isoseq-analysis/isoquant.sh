#!/bin/bash

ref=$1
geneDB=$2
bam=$3
output_prefix=$4

echo -e "isoquant.py \
        --reference ${ref} \
        --genedb ${geneDB} \
        --bam ${bam} \
        --data_type pacbio_ccs \
        -o ${output_prefix} \
        --check_canonical --count_exons --threads $SLURM_CPUS_PER_TASK && touch isoquant.done\n"


isoquant.py \
	--reference ${ref} \
	--genedb ${geneDB} \
	--bam ${bam} \
	--data_type pacbio_ccs \
	-o ${output_prefix} \
	--check_canonical --count_exons --threads $SLURM_CPUS_PER_TASK && touch isoquant.done
