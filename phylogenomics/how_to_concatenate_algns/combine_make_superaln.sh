if [ ! -f expected ]; then
 bash your_path/jobs/make_expected_file.sh
fi
perl your_path/combine_fasaln.pl -o your_concatenated_algn -of fasta -d aln_final -expected expected &> your_concatenated_algn.log
