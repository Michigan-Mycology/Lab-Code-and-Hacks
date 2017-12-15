head -q -n1 your_path/*.aa.fasta | awk -F\| '{print $1}' | awk '{print $1}' > expected
