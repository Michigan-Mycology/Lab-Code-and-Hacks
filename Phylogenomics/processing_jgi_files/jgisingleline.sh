for file in jgi/*.aa.fasta
do
let count++
m=${file/.aa.fasta/}
cat $file | awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' > "$m"_single_line.aa.fasta
done
echo "Final names fasta files prepared"
