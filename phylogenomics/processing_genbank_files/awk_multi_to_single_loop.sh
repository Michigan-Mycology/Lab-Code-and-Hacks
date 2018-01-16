for file in [your folder]/*_penultimate_names.aa.fasta
do
let count ++
m= ${file/_penultimate_names.aa.fasta/}
cat $file | awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);} END {printf("\n");}' > "$m"_final_names.aa.fasta
done
echo "All the single ladies! All the single ladies! Put your hands up!"
