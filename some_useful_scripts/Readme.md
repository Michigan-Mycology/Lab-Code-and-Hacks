# Some Useful Bioinformatic Scripts

This folder contains a collection of scripts that I wrote to deal with various obstacles and expedite certain aspects of genome sequence analysis and functional genomics. Some of them are still a tad rough, but they all accomplish what they're supposed to. The rest of this README contains information about how to run them and what they do. Feel free to contact me with any issues that you have.

## *better\_maker\_labels.sh*

**Usage:** `sh better_maker_labels.sh maker_map_ids_out prefix`

The protein annotation software, *Maker*, yields a protein fasta with really abnoxious sequence labels. You can use some of the scripts that ship with *Maker* to improve these labels, but then you loose any useful information that may have been in the original sequence header. For me, I wanted to retain the contig\_id, length, and coverage information from the nucleotide contig that the protein was originally called from. So, I made this script which will retain the original label in
addition to a new prefix that you specify. 
You need to provide the output from running *maker_map_ids* and the prefix you'd like to use. This script is meant to be run after *map_maker_ids* as part of the post-processing pipeline outlined [here](https://github.com/Michigan-Mycology/Lab-Code-and-Hacks/blob/master/Maker_pipeline/Maker_workflow_flux.txt).

## *count\_dbcan\_families.py*

**Usage:** `python countCazyFams.py list_dir outputs_dir`

This script does a batch count of the cazymes present in genomes. Tell this script the directory where you have all your input protein fastas (list\_dir) and where you have the output folders (output\_dir). Note the file and folder names need to start with the species identifier followed by an underscore (eg **AmanitaMuscaria\_**&#8203;proteins.fasta). Also note that this identifier needs to be the same between the list\_dir and output\_dir. You don't need to worry so much about
this if you just use my [makepbs\_batch.pbs](https://github.com/Michigan-Mycology/Lab-Code-and-Hacks/blob/master/some_useful_scripts/makepbs_batch.sh) to make your pbs scripts for conducting the dbCAN, merops, and interproscan portions of functional annotation. Outputs a csv that can be easily imported into Excel, R, etc. Requires pandas module of python.


## *count\_merops.py*

**USAGE:** `python count_merops.py list_dir outputs_dir lib`

This script does a batch count of merops protease families present in genomes. See description for *count_dbcan_families.py* for details on what to enter for list\_dir and outputs\_dir. Option lib refers to the location of the merops fasta file. Again, since this script is not extrememly generalized for different file and folder names, I suggest generating your initial pbs scripts for functional annotation using my
[makepbs\_batch.pbs](https://github.com/Michigan-Mycology/Lab-Code-and-Hacks/blob/master/some_useful_scripts/makepbs_batch.sh) script. Outputs a csv that can be easily imported into Excel, R, etc. Requires pandas module of python.

## *fragment_genome.py*

**USAGE:** `python fragment_genome.py genome_fasta`

This script takes a genome fasta and breaks contigs into smaller fragments of random sizes between the 'low' and 'high' variables hard-coded towards the top of the script - edit to whatever you like. You can also change the prefix for the fragments to have after fragmentation - also hard-coded.

## *generate_fastortho_opt_file.sh*

**USAGE:** `sh generate_fastortho_opt_file.sh list_dir output analysis_out_dir job_name`

This script makes it easy to create a fastortho options file without typing in all the paths to the single genome fastas. Specify the directory where all your fastas are (list\_dir), the path you'd like to output the options file to (output), the working directory for the actual fastortho analysis (analysis\_out\_dir) and the name for the run (job\_name).

## *getVennClusterNums.py*

**USAGE:** `python getVennCluserNums.py taxaIDfile fastortho.end Key?(True|False)`

