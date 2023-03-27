#!/bin/bash
## ./metagenomica.sh <forward> <reverse> <nombre>
## cat file.txt | xargs -n 3 -P 3 -I {} ./metagenomica.sh {}"_R1.fastq.gz" {}"_R2.fastq.gz" {}
### crea las carpetas assembly , conting y Kraken
## mkdir assembly conting Kraken
R1=$1
R2=$2
FILE=$3

## metaensamblaje 
metaspades.py -t 12 -1 $R1 -2 $R2 -o assembly/${FILE}

## mover los scaffolds a la carpeta conting
cp assembly/${FILE}/scaffolds.fasta conting/{FILE}.fasta

### indexar genomas humano
## bowtie2-build --threads 30  GCF_000001405.40_GRCh38.p14_genomic.fna $HOME/Documents/monkeypox_sequencing/reference/h38

## filtrar los contings que se alienan al genoma humano
bowtie2 -p 20 -x $HOME/Documents/monkeypox_sequencing/reference/h38 -f {FILE}.fasta -S {FILE}.sam

samtools -bS {FILE}.sam > {FILE}.bam
samtools bam2fq -f 4 {FILE}.bam | seqtk seq -A > ${FILE}_filtrado.fa

## identificar los contings con Kraken (TX ID)
kraken2 --report Kraken/${FILE}.txt --db $HOME/DB/kraken_db/minikraken2_v2_8GB_201904_UPDATE/ ${FILE}_filtrado.fa --output Kraken/${FILE}.out

## extraer 2 columnas (nombre y txID)
cut -f2,3 ${FILE}.out > ${FILE}.input

### install krona
### miniconda 
conda create -c bioconda -n krona_env krona  -y
conda activate krona_env
mkdir /home/test1/miniconda3/envs/krona_env/bin/taxonomy
ktUpdateTaxonomy.sh 
cd opt/krona/scripts/
mkdir bin/scripts
cd bin/taxonomy/
cd scripts/
ln -s ~/miniconda3/envs/krona_env/opt/krona/scripts/taxonomy.make .
ktUpdateTaxonomy.sh
ln -s /home/test1/miniconda3/envs/krona_env/opt/krona/scripts/extractTaxonomy.pl .
ktUpdateTaxonomy.sh
cd ~/miniconda3/envs/krona_env/opt/krona/taxonomy/
./updateTaxonomy.sh

### Anaconda




### ejecutar krona
ktImportTaxonomy ${FILE}.input -o ${FILE}.html
