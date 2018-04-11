for file in cleanup/*_final_names.aa.fasta
do
let count++
m=${file/_final_names.aa.fasta}
cp $file "$m"_dirty_final_names.aa.fasta
done
echo "Done with dirty files"
for file in cleanup/*_dirty_final_names.aa.fasta
do
let count++
n=${file/_dirty_final_names.aa.fasta}
cat $file "$n"_dirty_final_names.aa.fasta | tr "\." "_" | tr "\#" "_" | tr "\," "_" | tr "\:" "_" | tr "\;" "_" |  tr "\(" "_" |  tr "\)" "_" | tr "\-" "_" > "$n"_final_names.aa.fasta
done
echo "Final files generated"
