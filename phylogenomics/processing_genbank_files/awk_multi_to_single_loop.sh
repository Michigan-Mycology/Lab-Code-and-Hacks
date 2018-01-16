for file in [your folder]/*
do
let count ++
m= ${file//}
cat $file | awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);} END {printf("\n");}' > "$m"_final_names.aa.fasta
done
echo "All the single ladies! All the single ladies! Put your hands up!"
