#! /bin/bash

if [[ "$#" -lt 4 ]]; then
  echo "Usage: sh submit_norm.sh CPU_PER_TASK MEM(g) JOB_NAME SCRIPT [args] [extra]"
  exit -1
fi

cpus=$1
mem=$2
name=$3
script=$4
args=$5
partition=multinode
walltime=72:00:00
path=`pwd`
extra=$6
date=`date | sed -e s'/ /_/g'`


mkdir -p logs
log=logs/${name}.${date}.log

echo "\
sbatch -J $name --mem=$mem --constraint=x2680 --ntasks=${cpus} --ntasks-per-core=1 --partition=$partition -D $path $extra --time=$walltime --error=$log --output=$log $script $args"
sbatch -J $name --mem=$mem --constraint=x2680 --ntasks=${cpus} --ntasks-per-core=1 --partition=$partition -D $path $extra --time=$walltime --error=$log --output=$log $script $args

