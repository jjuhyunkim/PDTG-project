#!/bin/bash

set -e
module load blast
dbloc='/fdb/blastdb/'
query=$1
dbName=$2
prefix=$3

blastp \
-query ${query} \
-db ${dbloc}/${dbName} \
-out ${prefix}_${dbName}.pblast.txt \
-outfmt 6 \
-evalue 1e-5 \
-max_target_seqs 1 \
-num_threads $SLURM_CPUS_PER_TASK

sed -i '1i qseqid\tsseqid\tpident\tlength\tmismatch\tgapopen\tqstart\tqend\tsstart\tsend\tevalue\tbitscore' ${dbName}.pblast.txt

