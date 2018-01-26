for file in pep/*.aa.fasta
do
hmmsearch -E1e-8 --domtblout "$file".domtbl markers_3.hmmb "$file" &> "$file".log
done
