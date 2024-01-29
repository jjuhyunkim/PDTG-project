# Haplotype specific transcripts analysis wrapper. 
This repository aims to discover and quantify haplotype-specific transcripts using Illumina short-read RNA data or HiFi data from VCFs or assemblies.

## Installation and dependencies.
```bash
VGtools > 1.5.0 (for using vg rna)
rpvg
whatshat (if you start with VCFs)
cactus (if you start with assemblies)
```

## Run wrapper
### Start with using VCF and vg autoindex 
#### Step 1.1 Phasing variants
If you begin with VCF files to build the graph, you first need to phase the variants. Then, you can use the wrapper.

In this document, we used whatshap, but it would be okay to use other tools to phase variants.
```bash
# Phase variants
```

#### Step 1.2 Running wrapper
Use wrapper

```bash
sh ${script}/Mainscript.autoindexRun.sh \
  $ref $phasedVCF $gtf \
  $graph_prefix $sample_prefix \
  $rna_fastq1 ($rna_fasta2)
```

* ref : reference you want to use.
* phasedVCF : phased VCF file generated step1.1
* graph_prefix : prefix for graph that will be built using reference and variants. All graph and other files generated under 03.pantranscriptome/
  <details>
    <summary>graph files</summary>
    These are the outputs from vg autoindex. See vg tools github for details. 
    
    - ${graph_prefix}.haplotx.gbwt
    - ${graph_prefix}.spliced.xg
    - ${graph_prefix}.spliced.gcsa
    - ${graph_prefix}.spliced.gcsa.lcp
    - ${graph_prefix}.txorigin.tsv
      
  </details>

* sample_prefix : the prefix for alignment and quantification files.
  *  alignment file will be under 04.multimapping directory and named $sample_prefix..aligned.gamp
  *  quantification file will be under 05.quantification directory and named $sample_prefix.aligned.gamp

*  rna_fastq : if you have short-read paired RNA-seq data, give both of them at the end of the arguments. If you give only one fastq, this wrapper recognize that you give long read data.
