# This is a guide on how to quality control, trim, assemble, and bin dirty genomic data, i.e., metagenomic samples in which you want only one of the genomes.
This guide assumes you are working with illumina reads. Example pbs scripts and other scripts are available here as well as in the bioinformatics folder on the lsa server.

Because the files are so large, it is recommended you work in /scratch/lsa-flux/[your uniq id]

## Fast Quality Report

Load the latest version of the fastqc module. To check to see what the latest version is, run "module spider fastqc". fastqc is compatible with .zip and .gz file formats so there is no need to unzip them

`module load fastqc/0.11.5`

Generate a list of the files in your current working directory

`ll -tr`

`fastqc [file names for forward & reverse reads]`

fastqc will run directly on the command line. It will output an html report file for each fastq file. Download these html files to your computer and open them in your favorite interent browser. Use the graphs/data to determine how much to trim from the sequences and at what phred score.


IMPORTANT: the latest version will tell you the number of sequences that are contaminated with barcodes and what barcodes they are contaminated with. This data is necessary for trimming.

## Trimming

From this point, this guide will assume you used a Nextera kit to prepare the samples for sequencing. If you used another method, you must adjust the steps below accordingly. If your data is contaminated with the Nextera transposase sequence (they will be), then you will need an edited version of the sequence fasta file. An edited version is uploaded to this folder for your convience. 

Use trimmomatic to trim your sequences. Again, trimmomatic can handle compressed files. If you are using Nextseq, it outputs the data as if you ran 4 lanes. This guide assumes this is how your data is. If it is not, adjust accordingly. An example trimmomatic pbs script is in the folder.

If you need to change trimmomatic settings, the manual can be found here: http://www.usadellab.org/cms/?page=trimmomatic (It is not the best.)

`module load trimmomatic`

Make the necessary changes to the pbs script.

`vi trimmomatic.pbs`

Submit the job.

`qsub trimmomatic.pbs`

Once the trimmomatic job has finished, run the output files through fastqc a second time to ensure that all of the sequences have been adequately trimmed and all of the barcodes/adaptors have been removed. If the fastqc reveals the trimmomatic was not sucessful, you will have to fiddle with the trimmomatic options. If you are using something other than Nextera, you might have to modify the barcode/adpator fasta file in order to use the palindrome option. If everything looks good, then you can proceed to assembling.


## Assembly

I have been fairly sucessful using spades to assemble. There is an example spades pbs script in this folder. Usually, I run spades in the default normal mode. However, when dealing with potential/known metagenomes, it is best to run it both in normal mode and as metaspades (--meta). Then compare the results. The spades manual can be found here: http://spades.bioinf.spbau.ru/release3.10.0/manual.html

NOTE: metaSpades does not allow for more than one library to be assembled at a time.

`module load spades/3.10.0`

Edit the pbs script(s) as necessary.

`vi spades.pbs`

`vi spades_meta.pbs`

Submit the job(s).

`qsub spades.pbs`

`qsub spades_meta.pbs`

This may take up to a week. If the spades assembly stops unexpectedly, it can be started again and run from the last save point by adding "--continue" to the pbs script.

Once the assembly is finished, remove small contigs using the perl script provided in this folder. We usually start with 1000. For naming the new file, I reccommend the format genus/species_assembly-method_contig-size-removed.fasta

`perl remove_small_contigs.pl 1000 scaffolds.fasta > [insert new file name]`

Now to generate some stats using a creative commons perl script, which is also in this folder.

`perl assemblathon_stats.pl [insert file name]`

I do two things with this info: First, I will direct it to a new text file for sotrage. Second, I will input it in an Exel sheet or a Google Sheet so that I can compare it to other assemblies.

## Genome Binning with ESOM

Once you are satisfied with the assembly, it is time to start sorting out the target genome from everything else.

We will start by generating a taxonomy report. Perform a megablast search of your assembly. An example pbs script of how to do so is in this folder.

IMPORTANT: You must use ncbi-blast/2.2.29 for this, otherwise you will not get a taxonomy report. 

Once you have the output from blast, run the script "blast_taxonomy_report.pl" that can be found in this folder. You will also need the names, nodes, and gi_id file found on the LSA server. (Theya re too big to be loaded onto GitHUb.)

`perl blast_taxonomy_report.pl -blast -nodes nodes.dmp -names names.dmp -gi_taxid_file gi_taxid_nucl.dmp.gz > blast_taxonomy_report.txt`

Open the blast_taxonomy_report.txt file in Excel. Everything should be classified. What you will need to do is code the taxonomy into a numerical system and number the contigs appropriately. Example files are provided in this folder.

For example:
0 Unclassified
1 Bacteria
2 Ascomycota
3 Basidiomycota
etc.

Your final version should look like the following:
Contig1 0
Contig2 3
COntig4 1
etc. 

Save this as a tab delimited file. I reccommend a file name such as organism_taxonomy_annotation.txt This file will be used with the '-a' flag in the print tetramer frequencies script.

Now run ESOM according to the instructions found in the folder "Running_ESOM". https://github.com/Michigan-Mycology/Lab-Code-and-Hacks/tree/master/Running_ESOM

You have your genome.
