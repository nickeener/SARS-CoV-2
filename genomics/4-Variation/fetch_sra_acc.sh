#!/bin/bash 
set -e

GENOME_FASTA="current_complete_ncov_genomes.fasta"
GENOME_ACCESSIONS="genome_accessions.txt"

# From genbank, used to get SRR accessions as well as MT accessions for genomes
curl -s https://www.ncbi.nlm.nih.gov/core/assets/genbank/files/ncov-sequences.yaml --output ncov-sequences.yaml
grep -o "SRR[[:digit:]]\+" ncov-sequences.yaml > genbank.txt

# From SRA
IDS=$(curl 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=sra&term=txid2697049\[Organism%3Anoexp\]&retmax=1000' | grep "<Id>" | grep -o "[[:digit:]]\+" | tr "\n" ",")
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=sra&amp;id=$IDS" | grep -o "SRR[[:digit:]]\+" | sort | uniq > sra.txt

# From ENA
curl -s 'https://www.ebi.ac.uk/ena/browser/api/xml/links/taxon?accession=2697049&result=read_run&download=true' | grep -o "SRR[[:digit:]]\+" > ena.txt

cat ena.txt genbank.txt sra.txt | sort | uniq > union.txt
rm ena.txt
grep -f acc2exclude.txt -v union.txt > current.txt

# Annotate combined accession with metadata
pysradb metadata $(<current.txt) --saveto current_metadata.txt

# Split into Illumina and GridION datasets
grep -e 'Illumina\|NextSeq' current_metadata.txt |cut -f15 > current_illumina.txt
grep GridION current_metadata.txt |cut -f15 > current_gridion.txt

grep -B 2 'gene-region: complete$' ncov-sequences.yaml|grep -o "MT[[:digit:]]\+" > "NEW_$GENOME_ACCESSIONS"

# Get only new accessions we haven't seen before
if [ -f "$GENOME_ACCESSIONS" ]
then
    MT_ACCESSIONS=$(grep -f "$GENOME_ACCESSIONS" -v "NEW_$GENOME_ACCESSIONS" || true)
    if [ -z "$MT_ACCESSIONS" ]
    then
      echo "No new accessions found"
      exit 0
    fi
else
    MT_ACCESSIONS=$(cat "NEW_$GENOME_ACCESSIONS")
fi

# Replace newlines with comma so we query all accessions in one go
MT_ACCESSIONS=$(echo "$MT_ACCESSIONS"| tr "\n", ",")
curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=$MT_ACCESSIONS&rettype=fasta" | sed '/^$/d' >> "$GENOME_FASTA"

# Cleanup files we don't want to commit
rm ncov-sequences.yaml
mv "NEW_$GENOME_ACCESSIONS" "$GENOME_ACCESSIONS"
