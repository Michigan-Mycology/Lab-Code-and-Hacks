#Module load bioperl
#Be sure the best hits from the hmm search are in a directory labelled 'search'

perl your_path/construct_unaln_files.pl -d search -db your_dir -o aln

#construct_unaln_files.pl is available on the Spatafora et al. GitHub page.
#Must make the following changes to the construct_unaln_files.pl:
#Change my $dbdir = ''; to the name of the directory in which your final amino acid fasta files are located.
