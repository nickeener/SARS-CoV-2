---
title: Natural Selection Analysis
---

<observableNotebook notebookSource="@spond/natural-selection-analysis-of-sars-cov-2-covid-19"/>

# Analysis of Selection in the COVID-19 Genome

## Why Does Selection Matter?

Identifying the sites in a genome that are under selection, in addition to the type of selection at that site, can allow one to establish a set a candidate sites that may be responsible for evolutionary changes in an organism. For viral organisms such as COVID-19, this could also allow potential antigenic sites to be identified.

## Types of Selection We're Interested In

**Positive Pervasive**: Sites with a dN/dS > 1 are accumulating non-synonyomous changes (some of which might have a functional impact, but most probably don't) faster relative to synonymous changes than would be expected under neutral evolution.

**Positive Episodic**: This pattern is consistent with periods of evolutionary change followed by conservation or neutral evolution.

**Negative Pervasive**: Sites with a dN/dS < 1 are conserved, i.e. non-synonymous changes might be selected against. 

Note that sites with no changes (i.e. perfectly conserved sites) cannot be detected by dN/dS based methods

## Galaxy Workflow

We have created a [Galaxy workflow](https://usegalaxy.org/u/nickeener/w/imported-imported-evolution-analysis-1) that will allow anyone to identify sites that may be under selection. It will take a reference and the start/end coordinates of a gene/orf of interest, excise the appropriate subsequence from the reference, then use pairwise alignments to find the corresponding homologous subsequences from a set of full genomes to be aligned (called "reads" here). Identical sequences will be compressed into a single sequence at this step. It will then perform a codon-aware MSA of those sequences with the reference sequence (this is all done by the tool Kc-Align). The resulting alignment is used to produce a phylogenetic tree file (.nhx) using IQ Tree. The alignment fasta and nhx file from IQ Tree are then fed to HyPhy tools (SLAC, FEL, MEME, PRIME) which will perform the actual selection analysis. The alignment fasta is also given to TN93, which will calculate genetic distance using Tamura Nei 93 distance, allowing the level of diversity/divergence to be calculated.

### Inputs

The workflow requires three input files to function:

1. The full genome of a high confidence and well-annotated [reference sequence](https://github.com/nickeener/SARS-CoV-2/blob/master/evolution/examples/reference.fasta).

2. A FASTA file containg the genomes to be aligned (AKA [reads](https://github.com/nickeener/SARS-CoV-2/blob/master/evolution/examples/reads.fasta)).

3. A [tabular file](https://github.com/nickeener/SARS-CoV-2/blob/master/evolution/examples/genes.tab) wherein the first column is the name of the gene/orf, the second column are the start positions, and th third column are the end positions. Note for genes/orfs that appear in multiple separate segments or shift reading frame part-way through, each segments start positions appear together separated by a comma, and the same should also be true of the end positions, see RNA-dependent_RNAP in [example](https://github.com/nickeener/SARS-CoV-2/blob/master/evolution/examples/genes.tab).

### Outputs

The workflow will output five collections when complete. These are the outputs of the four HyPhy tools (PRIME, SLAC, MEME, FEL) and TN93 and each item within these collections will be the result of running that tool on each gene given as input (the name of each item in the collection will be the same as the gene name given in the tabular input.

### What Can the Outputs Tell Us?

**PRIME** (Property Informed Model of Evolution): Does evolution at specific sites in a coding alignment preserve or alter some biochemical properties?

Identify biochemical evolutionary constraints or changes with site level resolution: e.g. site 23 is evolving to conserve residue polarity, but alter it's volume.

**SLAC** (Single Likeliehood Ancestor Counting): Which site(s) in a gene are subject to pervasive, i.e. consistently across the entire phylogeny, diversifying selection?

The phenomenon of pervasive selection is generally most prevalent in pathogen evolution and any biological system influenced by evolutionary arms race dynamics (or balancing selection), including adaptive immune escape by viruses. As such, SLAC is ideally suited to identify sites under positive selection which represent candidate sites subject to strong selective pressures across the entire phylogeny. SLAC provides legacy functionality as a counting-based method adapted for phylogenetic applications. In general, this method will be the least statistically robust (compared to FEL or FUBAR), but it is the most directly interpretable.

**MEME** (Mixed Effects Model of Evolution): Which site(s) in a gene are subject to pervasive or episodic, i.e. only on a single lineage or subset of lineages, diversifying selection?

The phenomenon of pervasive selection is generally most prevalent in pathogen evolution and any biological system influenced by evolutionary arms race dynamics (or balancing selection), including adaptive immune escape by viruses. MEME is ideally suited to identify sites under positive selection which represent candidate sites subject to strong selective pressures across the entire phylogeny or only on parts of the phylogeny.

**FEL** (Fixed Effect Likelihood): Which site(s) in a gene are subject to pervasive, i.e. consistently across the entire phylogeny, diversifying selection?

The phenomenon of pervasive selection is generally most prevalent in pathogen evolution and any biological system influenced by evolutionary arms race dynamics (or balancing selection), including adaptive immune escape by viruses. As such, FEL is ideally suited to identify sites under positive selection which represent candidate sites subject to strong selective pressures across the entire phylogeny.

For help interpreting the JSON outputs of the HyPhy tools, see the [documentation](http://hyphy.org/resources/json-fields.pdf). Visualization methods for the HyPhy tools (except for PRIME) can be found [here](http://vision.hyphy.org/)
