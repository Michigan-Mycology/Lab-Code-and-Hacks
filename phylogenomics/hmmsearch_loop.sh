for i in pep_final_names/*.aa.fasta
do
hmmsearch -E1e-8 --domtblout "$i".domtbl markers_3.hmmb "$i" &> "$i".log
done
