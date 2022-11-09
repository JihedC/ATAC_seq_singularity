# ATAC_seq_Snakemake
A snakemake pipeline for the analysis of ATAC-seq data

[![Snakemake](https://img.shields.io/badge/snakemake-≥5.2.0-brightgreen.svg)](https://snakemake.bitbucket.io)
[![Miniconda](https://img.shields.io/badge/miniconda-blue.svg)](https://conda.io/miniconda)

# Aim
Snakemake pipeline made for reproducible analysis of paired-end Illumina ATAC-seq data. The desired output of this pipeline are:
- fastqc zip and html files
- bigWig files (including bamCompare rule)
- bed files

# How to use the Snakemake pipeline -- TLDR

- download the pipeline: `git clone https://github.com/JihedC/ATAC_seq_singularity.git`
- change directory to the newly downloaded pipeline: `cd ATAC_seq_singularity/`
- if conda is not installed:
  - download miniconda3: `wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh`
  - install miniconda in your folder: `sh Miniconda3-latest-Linux-x86_64.sh`
  Say yes for the licence terms and either ENTER to confirm the location of installation or choose another location for the installation.
  After the installation you will need to restart your terminal and reconnect to the HPC.
  At the restart, "(base)" should appear on the left side of the prompt which means that you are in the base environment
- install Mamba: `conda install -n base -c conda-forge mamba`  this might take a while, but it's worth it because it will make conda much faster. Accept all the install.
- activate the base environment: `conda activate base`
- install snakemake with mamba: `mamba create -c conda-forge -c bioconda -n snakemake snakemake` Accept the insllation with "Y"
- activate the snakemake environment: `conda activate snakemake`
- control that you are in the folder containing the workflow/pipeline: `pwd`
- Use the dry run option to check that the download pipeline should work: `snakemake -np` if nothing appears in red, the pipeline should work.
- Adapt the units.tsv file to your sample name and their path on the HPC. Make sure that the columns are tab seaparated values.
- Use the dry run option to check that the pipeline will run now that the units.tsv is adapted: `snakemake -np` if nothing appears in red, the pipeline should work.
- Start the pipeline: `sbatch slurm_snakemake.sh`

Snakemake makes uses of **singularity** to pull images of Dockers containers. Dockers containers contains the softwares required for the rules set up in the Snakemake workflow.
**Singularity is a must and will most likely be the source of error** 
For now I have hard coded the module loaded by Shark: `module load container/singularity/3.10.0/gcc.8.5.0`. If in the future, this module is removed from Shark or modified, it might prevent the pipeline from working because it will not be able to pull containers. This line of code would then need to be modified in the file `slurm_snakemake.sh`.
This line would need to be replaced by the line obtained after running `module spider singularity` on Shark.

# Content of the repository

- **Snakefile** containing the targeted output and the rules to generate them from the input files.

- **config/** , folder containing the configuration files making the Snakefile adaptable to any input files, genome and parameter for the rules. Adapt the config file and its reference in the Snakefile. Please also pay attention to the parameters selected for deeptools, for convenience and faster test the **bins** have been defined at `1000bp`, do not forget to adapt it to your analysis.

- **Fastq/**, folder containing subsetted paired-end fastq files used to test locally the pipeline. Generated using [Seqtk](https://github.com/lh3/seqtk): `seqtk sample -s100 read1.fq 5000 > sub1.fqseqtk sample -s100 read2.fq 5000 > sub2.fq`. RAW fastq or fastq.gz files should be placed here before running the pipeline.

- **envs/**, folder containing the environment needed for the Snakefile to run. To use Snakemake, it is required to create and activate an environment containing snakemake (here : envs/global_env.yaml )

- **units.tsv**, is a tab separated value files containing information about the experiment name, the condition of the experiment (control or treatment) and the path to the fastq files relative to the **Snakefile**. **Change this file according to your samples.**

- **rules/**, folder containing the rules called by the snakefile to run the pipeline, this improves the clarity of the Snakefile and might help modifying the file in the future.


# Usage

## Conda environment

First, you need to create an environment for the use of Snakemake with [Conda package manager](https://conda.io/docs/using/envs.html).
1. Create a virtual environment named "chipseq" from the `global_env.yaml` file with the following command: `conda env create --name chipseq --file ~/envs/global_env.yaml`
2. Then, activate this virtual environment with `source activate chipseq`

The Snakefile will then take care of installing and loading the packages and softwares required by each step of the pipeline.

## Configuration file

The `~/configs/config_tomato_sub.yaml` file specifies the sample list, the genomic reference fasta file to use, the directories to use, etc. This file is then used to build parameters in the main `Snakefile`.

## Snakemake execution

The Snakemake pipeline/workflow management system reads a master file (often called `Snakefile`) to list the steps to be executed and defining their order.
It has many rich features. Read more [here](https://snakemake.readthedocs.io/en/stable/).

## Samples

Samples are listed in the `units.tsv` file and will be used by the Snakefile automatically. Change the name, the conditions accordingly.

## Dry run

Use the command `snakemake -np` to perform a dry run that prints out the rules and commands.

## Real run

Simply type `Snakemake --use-conda` and provide the number of cores with `--cores 10` for ten cores for instance.
For cluster execution, please refer to the [Snakemake reference](https://snakemake.readthedocs.io/en/stable/executable.html#cluster-execution).
Please pay attention to `--use-conda`, it is required for the installation and loading of the dependencies used by the rules of the pipeline.
To run the pipeline, from the folder containing the Snakefile run the

# Main outputs

The main output are :

- **fastqc** : Provide informations about the quality of the sequences provided and generate a html file to visualize it. More information to be found [here](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)

- **bed** : Provide information generated by the MACS2 algorithm for the locations and significance of peaks. These files can be used for direct visualization of the peaks location using IGV or as an input for further analysis using the [bedtools](https://bedtools.readthedocs.io/en/latest/content/bedtools-suite.html)

- **bigwig files** : Provides files allowing fast displays of read coverages track on any type of genome browsers.

- **plotFingerprint** contains interesting figures that answer the question: **"Did my ChIP work???"** . Explanation of the plot and the options available can be found [here](https://deeptools.readthedocs.io/en/develop/content/tools/plotFingerprint.html)

- **PLOTCORRELATION** folder contain pdf files displaying the correlation between the samples tested in the ChIP experiment, many options in the plotcorrelation rules can be changed via the configuration file. More information about this plot can be found [here](https://deeptools.readthedocs.io/en/develop/content/tools/plotCorrelation.html)

- **HEATMAP** folder contain pdf files displaying the content of the matrix produced by the `computeMatrix` rule under the form of a heatmap. Many option for the `computeMatrix` and the `plotHeatmap` rules can be changed in the configuration file. More information about this figure can be found [here](https://deeptools.readthedocs.io/en/develop/content/tools/plotHeatmap.html).

- **plotProfile** folder contain pdf files displaying profile plot for scores over sets of genomic region, again the genomic region are define in the matrix made previously. Again there are many options to change the plot and more information can be found [here](https://deeptools.readthedocs.io/en/develop/content/tools/plotProfile.html)

Optionals outputs of the pipelines are **bamCompare**, **bedgraph** and **bed files for broad peaks calling**.