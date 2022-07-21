mkdir -p Project/{data,results,scripts}
cat (list of fasta files) > Project/data/gisaid.total.fasta
cat (list of metadata files) > Project/data/gisaid.total.metadata.tsv
head -n 1 gisaid.total.metadata.tsv > Project/data/metadata_select.tsv

for i in (list of fasta files);
do
    seqtk comp $i | awk  '{x=$3+$4+$5+$6;y=$2;print $1" "(1-(y-x)/y)*100}' | awk '$2 >= 99.99{print $1}';

done > Project/data/select.txt

for i in $(cat select.txt);do;fgrep $i gisaid.total.metadata.tsv >> Project/data/metadata_select.tsv;done

efetch -db nucleotide -id NC_045512.2 -format fasta > Project/data/genomes_select.fasta
samtools faidx Project/data/gisaid.total.fasta
samtools faidx Project/data/gisaid.total.fasta $(cat select.txt ) >> genomes_select.fasta
cd Project/data/

pangolin genomes_select.fasta --alignment --outfile  genomes_select_pangolin.csv --max-ambig 0.1 --min-length 28000 -t 14


cut -f 1 ../data/gisaid.total.metadata.tsv | sort -R | tail -n 500 > 500select.txt

samtools faidx ../data/gisaid.total.fasta $(cat 500select.txt) > 500select.fast


### zsh exe
### replace from file mutiple times 

awk '{print $1" "$1$5}' metadata_select500.tsv > file_rep.txt

while read -r pattern change;             
do
  sed -i "s&$pattern&$change&" 500select.fasta
done < file_rep.txt

