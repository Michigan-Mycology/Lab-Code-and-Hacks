for file in aln_final/*.msa.trim
do
let count++
m=${file/.msa.trim/}
echo "
#PBS -N raxml_"$m"
#PBS -V
#PBS -A lsa_flux
#PBS -l qos=flux
#PBS -q flux
#PBS -l nodes=10:ppn=2,pmem=1gb,walltime=15:00:00
#PBS -M [your_email]
#PBS -m ae
#PBS -j oe

#Your Code Goes Below:
cd [your_path]/phylogenomics/raxml_gene_trees
mpirun -np 20 raxmlHPC-MPI -f a -s [your_path/aln_final/"$m".msa.trim -n "$m".nex -m PROTGAMMAAUTO -x 25678 -N 100 -p 8762" > [your_path]/phylogenomics/raxml_gene_tree_scripts/"$m".pbs
done
