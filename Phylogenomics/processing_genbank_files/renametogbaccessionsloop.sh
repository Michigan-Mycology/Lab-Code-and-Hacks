for file in genbank/*.faa
do
let count++
m=${file/_protein.faa/}
cat $file | awk '{print$1}' | sed 's/\.1//g' > "$m"_gbacc.aa.fasta
done
echo "Sequences renamed to GenBank accessions"
