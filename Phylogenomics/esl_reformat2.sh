for FILE in aln/*.1.aln
do
let count++
m=${FILE/.1.aln/}
esl-reformat --replace=x:- clustal $FILE > $m.2.aln
done
