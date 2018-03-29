# Some Useful Bioinformatic Scripts

This folder contains a collection of scripts that I wrote to deal with various obstacles and expedite certain aspects of genome sequence analysis and functional genomics. Some of them are still a tad rough, but they all accomplish what they're supposed to. The rest of this README contains information about how to run them and what they do. Feel free to contact me with any issues that you have.

## *better\_maker\_labels.sh*

**Usage:** `sh better_maker_labels.sh maker_map_ids_out prefix`

The protein annotation software, *Maker*, yields a protein fasta with really abnoxious sequence labels. You can use some of the scripts that ship with *Maker* to improve these labels, but then you loose any useful information that may have been in the original sequence header. For me, I wanted to retain the contig\_id, length, and coverage information from the nucleotide contig that the protein was originally called from. So, I made this script which will retain the original label in
addition to a new prefix that you can specify.

## *count\_dbcan\_families.py*

## *count\_merops.py*
