for file in genbank/*_penultimate_names.aa.fasta
do
let count++
m=${file/_penultimate_names.aa.fasta/}
cat $file | awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' > "$m"_final_names.aa.fasta
done
echo "Final names fasta files prepared"
