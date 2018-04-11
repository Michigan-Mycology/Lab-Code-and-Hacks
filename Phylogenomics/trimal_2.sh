for FILE in aln/*.msa.filter
do
let count++
m=${FILE/.msa.filter/}
[your_path]/trimAl/source/trimal -automated1 -fasta -in $FILE -out "$m".msa.trim
done
