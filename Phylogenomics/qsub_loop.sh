for file in raxml_gene_tree_scripts/*.pbs
do
qsub "$file"
done
