## HG002 personalized transcriptome analysis project 


### methods
1. Build high quality human diploid genome by [HG002 Q100 project](https://github.com/marbl/HG002) (lead by [Nancy F. Hansen][(](https://github.com/nhansen)))
2. Generate diploid graph based on CHM13 using `minigraph-cactus`
3. Project transcriptome information on the graph to make pan-transcriptome graph using `vg` tools(`vg rna`)
4. Align the sequencing data on the transcriptome graph using `vg mpmap`
5. Quantify haplotype specific expression using `rpvg`

### Data
* All codes used this project in this github repo(` Mainscript.sh `)
* The reference genome : CHM13v2.0 + chrM + chrEBV (linear)
* Human genome : HG002 diploid genome v101
* Gene annotation : CHM13 gene annotation / (+-novel isoforms discovered by using long read sequencing data)
* RNA dataset : short read (total, lncRNA, mRNA) and long read(HiFi, Mas, ONT cDNA, ONT direct) RNA sequencing data

### Viz
To visualize the data, we generated a `GFA` file containing all chromosomes produced by `minigraph-cactus` without sequences to reduce the file size. : `hg002v101.allGene.isoquantModel.all_chr.sv.gfa.gz`

### Troubleshooting
1. multimapping was done with successfully when i used short read paired end RNA seq data, but when I've tried to run `rpvg`, I encountered error stating: 
   * [github issue](https://github.com/jonassibbesen/rpvg/issues/63)
    ```bash
    rpvg: /home/rpvg/src/path_abundance_estimator.cpp:715: void NestedPathAbundanceEstimator::inferPathSubsetAbundance(PathClusterEstimates*, const std::vector<ReadPathProbabilities>&, std::mt19937*, const spp::sparse_hash_map<std::vector<unsigned int>, double>&) const: Assertion `path_group.second.size() <= group_size' failed.
    ```

    * 1st hypothesis : problem during estimate distance between paired end reads?
      * [fragment size estimation during vg mpmap and rpvg](https://www.biostars.org/p/9603638/)
    * 2nd hypothesis : too complex region
      * What i am going to try
        * Split chromosome or region to find the complex region
          * [issue : split gamp by chromosome or extract specific regions.](https://www.biostars.org/p/9605059/)

2. Question about result
   * [HST assignment : rpvg assigned two different homo HST instead of expected heterozygous transcripts. #59e](https://github.com/jonassibbesen/rpvg/issues/59)