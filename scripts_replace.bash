### zsh exe
### replace from file mutiple times 
while read -r pattern change;             
do
  sed -i "s&$pattern&$change&" 500select.fasta
done < file_rep.txt

