# Downloading and using Astral to create a species tree from multiple unrooted gene trees

  1. Use RAxML to produce the standard tree outputs. Create a new folder and copy the "RAxML_bipartitions.\*.nex" files to it. 
```
mkdir astral
cp RAxML_bipartitions.* ./astral/
```
  2. Navigate to the folder, and merge all nexus files into a single newick .tre file.
```
cd astral/
cat *.nex > astral.tre
```
  3. The merged file will contain different loci for the same taxa across the different trees, which will cause Astral to read only the first tree. At this point, the unnecessary data should be between a "|" and ":". Therefore, to delete the loci and retain the branch length information, run the following command line.
```
cat astral.tre | sed 's/|[^:]*:/:/g' > astral_clean.tre
```
  4. Obtain sed.txt file, and save it into the same folder as the single_line.aa.fasta files. In the final "sed" command, substitute the JGI abbreviation with your preferred abbreviation.
```
sed -f sed.txt Conidiobolus_coronatus_GeneCatalog_proteins_20120213_single_line.aa.fasta | awk '{print $1,"|",$3}' | sed 's/ //g'| sed 's/\*|//g' | sed 's/JGI_abbreviation/preferred_abbreviation/g' > JGIfilename_dirty_final_names.aa.fasta
```
  5. Edit the final_names.aa.fasta file to eliminate the first blank line.
```
vi JGIfilename_dirty_final_names.aa.fasta
```
  6. To remove extra symbols in contigs, obtain removeperiodsandpounds script, edit the appropriate folder and file names, and run.
```
sh removeperiodsandpounds.sh
```
  7. It is common for an extra pipe to be located at the end of the .fasta file. In order to delete these without deleting the pipe after the taxon name, first copy the file.
```
cp JGIfilenames_final_names.aa.fasta JGIfilename_final_names_with_pipes.aa.fasta
```
  8. Using the taxon abbreviation (or the last few letters), indicate that in all cases other than the pipe following the taxon, the pipes should be replaced by nothing.
```
cat JGIfilenames_final_names_with_pipes.aa.fasta | sed '/taxon_abbreviation|/! s/|//g' > JGIfilenames_final_names.aa.fasta
```
  9. Check that the number of contigs matches the number of pipes.
```
grep -c "^>" JGIfilenames_final_names.aa.fasta
grep -c "|" JGIfilenames_final_names.aa.fasta
```
