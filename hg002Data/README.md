## HG002 personalized transcriptome analysis project 


### methods
1. Build a high-quality human diploid genome through the  [HG002 Q100 project](https://github.com/marbl/HG002) (led by [Nancy F. Hansen](https://github.com/nhansen)
2. Generate a diploid graph based on CHM13 using  `minigraph-cactus`
3. Project transcriptome information onto the graph to create a pan-transcriptome graph using `vg` tools(`vg rna`)
4. Align sequencing data to the transcriptome graph using `vg mpmap`
5. Quantify haplotype-specific expression using `rpvg`

### Data
* All codes used this project in this github repo(`scripts/haplotype-transcript/Mainscript.sh`)
* The reference genome : CHM13v2.0 + chrM + chrEBV (linear)
* Human genome : HG002 diploid genome v101
* Gene annotation : CHM13 gene annotation / (+-novel isoforms discovered by using long read sequencing data)
* RNA dataset : short read (total, lncRNA, mRNA) and long read(HiFi, Mas, ONT cDNA, ONT direct) RNA sequencing data

### Viz
To visualize the data, we generated a `GFA` file containing all chromosomes produced by `minigraph-cactus` without sequences to reduce the file size. : `hg002v101.allGene.isoquantModel.all_chr.sv.gfa.gz`

### Troubleshooting
1. Multimapping was successfully performed when I used short-read paired-end RNA-seq data, but when I tried to run rpvg, I encountered an error stating:
   * [github issue](https://github.com/jonassibbesen/rpvg/issues/63)
    ```bash
    rpvg: /home/rpvg/src/path_abundance_estimator.cpp:715: void NestedPathAbundanceEstimator::inferPathSubsetAbundance(PathClusterEstimates*, const std::vector<ReadPathProbabilities>&, std::mt19937*, const spp::sparse_hash_map<std::vector<unsigned int>, double>&) const: Assertion `path_group.second.size() <= group_size' failed.
    ```
    cmd line I used : 
    ```bash
    rpvg -t 50 \
    --graph hg002v101.allGene.isoquantModel.pantranscriptome.xg \
    --paths hg002v101.allGene.isoquantModel.pantranscriptome.gbwt \
    --alignments hg002v101.allGene.isoquantModel.aligned.gamp \
    --output-prefix hg002v101.allGene.isoquantModel.rpvg \
    --path-info hg002v101.allGene.isoquantModel.pantranscriptome.txt \
    --inference-model haplotype-transcripts
    ```
    * 1st hypothesis : problem during estimate distance between paired end reads?
      * [fragment size estimation during vg mpmap and rpvg](https://www.biostars.org/p/9603638/)
    * 2nd hypothesis : too complex region
      * What i am going to try
        * Split chromosome or region to find the complex region
          * [issue : split gamp by chromosome or extract specific regions.](https://www.biostars.org/p/9605059/)

2. Multimapping was successfully performed when I used hifi long read single end RNA seq data, but when I tired to run `rpvg`, I encountered an error stating:
   ```bash
   rpvg: /home/rpvg/src/alignment_path_finder.cpp:472: std::vector<AlignmentSearchPath> AlignmentPathFinder<AlignmentType>::extendAlignmentSearchPath(const AlignmentSearchPath&, const vg::MultipathAlignment&) const [with AlignmentType = vg::MultipathAlignment]: Assertion `best_align_score <= optimal_score' failed.
    ```
    cmd line I used :
    ```bash
    rpvg -t 50 \
    --graph hg002v110_nonGene_ExtendAllGenes.pantranscriptome.xg \
    --paths hg002v110_nonGene_ExtendAllGenes.pantranscriptome.gbwt \
    --alignments hg002v110_nonGene_ExtendAllGenes.HG002_na24385_hifi.aligned.gamp \
    --output-prefix ./hifi \
    -f hg002v110_nonGene_ExtendAllGenes.pantranscriptome.txt \
    --inference-model haplotype-transcripts -s -l
    ```
3. Question about result
   * [HST assignment : rpvg assigned two different homo HST instead of expected heterozygous transcripts. #59e](https://github.com/jonassibbesen/rpvg/issues/59)