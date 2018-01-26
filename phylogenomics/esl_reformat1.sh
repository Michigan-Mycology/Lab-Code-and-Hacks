for FILE in aln/*.msa
do
let count++
m=${FILE/.msa/}
esl-reformat --replace=\*:- --gapsym=- clustal $FILE >"$m".1.aln
done
