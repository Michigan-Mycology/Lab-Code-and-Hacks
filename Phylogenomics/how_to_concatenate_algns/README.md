# Instructions on how to use scripts from the Spatafora et al. 2016 pipeline to concatenate individual gnee alignments
Scripts needed:
1. `combine_make_superaln.sh`
2. `make_expected_file.sh`
3. `combine_fasaln.pl` **NOTE** Must download this from the [Spatafora et al repository](https://github.com/zygolife/Phylogenomics/blob/master/Spatafora_et_al_2016/scripts/combine_fasaln.pl)
4. Be sure to load `bioperl`

## Step 1: Setting up headers of fasta files

First you need to set up your headers in the fasta files so that they follow the format "Organism_prefix|gene_name". I have included examples of how to do this for both Genbank and JGI genomes. Place all of the individual alignments in a folder named `/aln_final`. The `3 Spatafora et al.` scripts are set up to be in 3 different folders, but one can change that so that they are all in the same folder. You will need to make the following changes to run the scripts.

  1. For `combine_fasaln.pl`:
    - At line 9, insert whatever the file extention for your alignments is at my $ext = ''; . For example, for `aln1.fa`, you would edit it to read my $ext = 'fa'; . NOTE the absence of the '.'
  2. For `make_expected_file.sh`:
    - Change the file path after -nl to the location of your fasta files
    - **NOTE:** I find it works better if I make my own expected file. The expected file is simply a list of the ">Organism_prefix" header names in your files. In other words, it is a list of the linking names (>Organism_prefix) that the scripts will use to concatenate all of the genes.
    - `cat pep/*.aa.fasta | grep "^>" | tr "|" "\t" | cut -f 1 | sort | uniq > expected`
  3. For combine_make_superaln.sh:
    - Change the file paths to point to the appropriate locations of the `make_expected_file.sh` and `combine_fasaln.pl`.
    - -d should be `/aln_final` or whatever the directory your alignments are stored in.
    - -o is the name of the output file

## Step 2: 
`sh combine_make_superaln.sh`



