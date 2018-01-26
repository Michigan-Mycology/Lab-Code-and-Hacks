# #Downloading and editing JGI protein fasta files for downstream analyses

  1. Download .aa.fasta.gz files from JGI and put them in phylogenomics/messy_pep/jgi folder. To unzip them all, obtain, edit, and run the gzip_loop_jgi.sh script, or copy the command for a single file.
```
sh gzip_loo_jgi.sh
```
#JGI aa.fasta files contain wrapped sequences. To make them single_line, obtain, edit, and run the jgisingleline.sh script, or copy the command for a single file. 

sh jgisingleline.sh

#Rename fasta format abbreviations of taxa by first looking at single_line.aa.fasta file to determine abbreviation used.

head JGIfilename_single_line.aa.fasta 

#Obtain sed.txt file, and save it into the same folder as the single_line.aa.fasta files. In the final "sed" command, substitute the JGI abbreviation with your preferred abbreviation.

sed -f sed.txt Conidiobolus_coronatus_GeneCatalog_proteins_20120213_single_line.aa.fasta | awk '{print $1,"|",$3}' | sed 's/ //g'| sed 's/\*|//g' | sed 's/JGI_abbreviation/preferred_abbreviation/g' > JGIfilename_dirty_final_names.aa.fasta

#Edit the final_names.aa.fasta file to eliminate the first blank line.

vi JGIfilename_dirty_final_names.aa.fasta

#To remove extra symbols in contigs, obtain removeperiodsandpounds script, edit the appropriate folder and file names, and run.

sh removeperiodsandpounds.sh

#It is common for an extra pipe to be located at the end of the .fasta file. In order to delete these without deleting the pipe after the taxon name, first copy the file.

cp JGIfilenames_final_names.aa.fasta JGIfilename_final_names_with_pipes.aa.fasta

#Using the taxon abbreviation (or the last few letters), indicate that in all cases other than the pipe following the taxon, the pipes should be replaced by nothing.

cat JGIfilenames_final_names_with_pipes.aa.fasta | sed '/taxon_abbreviation|/! s/|//g' > JGIfilenames_final_names.aa.fasta

#Check that the number of contigs matches the number of pipes.

grep -c "^>" JGIfilenames_final_names.aa.fasta
grep -c "|" JGIfilenames_final_names.aa.fasta
