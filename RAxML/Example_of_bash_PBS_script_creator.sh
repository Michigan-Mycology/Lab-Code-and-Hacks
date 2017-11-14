for file in 
do
echo " 
#PBS -N raxml_$file
#PBS -V
#PBS -A lsa_flux
#PBS -l qos=flux
#PBS -q flux
#PBS -l nodes=12:ppn=5,pmem=1gb,walltime=15:00:00
#PBS -M @umich.edu
#PBS -m abe
#PBS -j oe

#Your Code Goes Below:
cd 
mpirun -np 60 raxmlHPC-MPI -f a -s $file -n tree_"$file".nex -m PROTGAMMAAUTO -x 25678 -N 500 -p 8762" > $file.pbs
done
