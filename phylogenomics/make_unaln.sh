#Module load bioperl
#Be sure the best hits from the hmm search are in a directory labelled 'search'
#construct_unaln_files.pl is available on the Spatafora et al. GitHub page.

perl your_path/construct_unaln_files.pl -d search -db pep -o aln
