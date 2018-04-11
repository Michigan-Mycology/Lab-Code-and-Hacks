for file in [your folder]/*.faa
do
let count ++
m= ${file/_protein.faa/}
cat $file | awk '{print $1}' | sed 's/\.1/g' > "$m"_renamed1.aa.fasta
echo "Seqs renamed"
