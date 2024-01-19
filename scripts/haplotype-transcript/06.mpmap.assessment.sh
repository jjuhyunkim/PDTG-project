#!/bin/bash

prefix=$1

vg view -K -G ${prefix}.gamp > ${prefix}.gam
vg stats -a ${prefix}.gam > ${prefix}.gam.stats
vg view -aj ${prefix}.gam | jq -r '[.name, .score, .mapping_quality, .is_secondary] | @tsv' > ${prefix}.mpmap.assessment.tsv
