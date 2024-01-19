#! /bin/bash

ref=$1
input=$2
output_prefix=$3

pbmm2 align -j $SLURM_CPUS_PER_TASK --preset ISOSEQ --sort \
        --sample $output_prefix \
	${ref} \
	${input} \
	${output_prefix}.pbmm2.bam && touch pbmm2.done
