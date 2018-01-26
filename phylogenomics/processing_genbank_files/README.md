# Downloading and editing GenBank protein fasta files for downstream analyses

  1. Download .faa.gz files from GenBank and put them in phylogenomics/messy_pep/genbank/ folder. To unzip them all, obtain, edit, and run the gzip_loop_genbank.sh script, or copy the command for a single file.
```
sh gzip_loop_genbank.sh
```
  2. Format the .faa files to gbacc.aa.fasta files and rename contigs with acession numbers (which will serve as the "locus" name).
```
sh renametogbaccessionsloop.sh`
```
  3. Format fasta headers to lead as [organism_name]|[locus_name].
```
cat genbankfilename_gbacc.aa.fasta | sed 's/>/>organism_name\|/g' > organism_name_penultimate_names.aa.fasta
```
  4. GenBank files contain wrapped sequences. To make them single_line from penultimate_names files, obtain, edit, and run the penultimatetosingleline.sh script, or copy and the command for a single file.
```
sh penultimatetosingleline.sh
```
