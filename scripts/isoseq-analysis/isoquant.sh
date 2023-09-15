#!/bin/bash

ref="/data/kimj75/00.Files/references/chm13v2/fa/chm13v2.0_maskedY_rCRS_wEBV.fa"
geneDB=$3
bam=$1
prefix=$2
geneDB=$3

echo -e "isoquant.py \
        --reference ${ref} --genedb ${geneDB} --bam ${bam} \
        --data_type pacbio_ccs -o ${prefix} \
        --check_canonical --count_exons --threads $SLURM_CPUS_PER_TASK"


isoquant.py \
	--reference ${ref} --genedb ${geneDB} --bam ${bam} \
	--data_type pacbio_ccs -o ${prefix} \
	--check_canonical --count_exons --threads $SLURM_CPUS_PER_TASK
