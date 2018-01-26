# Preparing spades output for ESOM analyses and managing ESOM output

1. Make folders ESOM, ESOM/tax, and ESOM/fasta in project folder
```
mkdir ESOM
mkdir ESOM/tax
mkdir ESOM/fasta
```
2. From within ESOM folder, copy edited .fasta file from spades output to ESOM folder
```
cp ../fastqc/filename_spades_1000contigsremoved.fasta ./
```
3. Obtain blastn.pbs, and place in ESOM folder. Modify for appropriate files and location.
```
vi blastn.pbs
```
4. Load ncbi module
```	
load module ncbi-blast/2.2.29
```
5. Submit blastn.pbs to flux, which will process for 2-3 hours.
```	
qsub blastn.pbs
```
6. Obtain and copy scripts to ESOM folder
```
cp /home/uniqueid/scripts/blast_taxonomy_report.pl ./
cp /home/uniqueid/scripts/gi_taxid_nucl.dmp.gz ./
cp /home/uniqueid/scripts/names.dmp ./
cp /home/uniqueid/scripts/nodes.dmp ./
cp /home/uniqueid/scripts/print_tetramer_freqs_deg_filter_esom_VD.pl ./
```
7. Run blast_taxonomy_report.pl in background of PuTTY
```
perl -blast [output file of blastn.pbs] -nodes nodes.dmp -names names.dmp -gi_taxid_file gi_taxid_nucl.dmp.gz > filename_blastreport.txt &
```
8. Once you have generated blast report, copy to Excel. Add a column to characterize taxa and save Excel sheet. Then delete all but contigs and characterization column and save as tab delimited filename_blastreport_annotation.txt file.

9. Copy print_tetramer_freqs_deg_filter_esom_VD.pl, original spades .fasta file, and blast report annotation .txt file into the tax folder. Enter folder and generate input files (.cls, .lrn, .names) for ESOM using perl script.
```
cp print_tetramer_freqs_deg_filter_esom_VD.pl ./tax/
cp filename_spades_1000contigsremoved.fasta ./tax/
cp filename_blastreport_annotation.txt ./tax/
perl print_tetramer_freqs_deg_filter_esom_VD.pl -s filename_spades_1000contigsremoved.fasta -m 1000 -w 3000 k -4 -a filename_blastreport_annotation.txt
```
10. Run ESOM using GitHub instructions: https://github.com/Michigan-Mycology/Lab-Code-and-Hacks/blob/master/Running_ESOM/Running_ESOM_instructions

11. From ESOM, resulting .cls file will be putative genome/bacterial contaminant/organelle DNA/etc. To extract those contigs from the original fasta file, obtain getClassFasta.pl and run on selected .cls file
```
perl /home/chytrids/scripts/getClassFasta.pl -fasta filename_spades_1000contigsremoved.fasta -names filename_spades_1000contigsremoved.fasta.names -num 1 -loyal 75 -cls filename_put_genome.cls
```
12. Results in .fasta and .conf files, which will need renaming, e.g. filename_put_genome. Copy into fasta folder.
```
cp filename_put_genome.fasta ../fasta/
cp filename_put_genome.conf ../fasta/
```
- *Optional*
12a. If you wish to see GenBank accessions for selected contigs, first save list of contigs from the appropriate .conf file.
```
cat filename_put_genome.conf | cut -f2 | grep "NODE" > ../filename_put_genome_contigs.txt
```
12b. Using original blastn output file, select contigs isolated with ESOM and get list of unique GenBank accessions.
```
cat filename_ntdb_evalue5 | grep -f filename_put_genome_contigs.txt | cut -f2 | tr "|" "\t" | cut -f4 | sort | uniq > filename_put_genome_contigs_gbaccessions.txt
```
