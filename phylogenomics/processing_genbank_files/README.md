# Downloading and editing GenBank protein fasta files for downstream analyses

  1. Download .faa files from GenBank and put them in phylogenomics/messy_pep/genbank/ folder. To unzip them all, obtain, edit, and run the gzip_loop_genbank.sh script, or copy the command for a single file.
```
sh gzip_loop_genbank.sh
```
  2. To get just the acession numbers (which will serve as the "locus" name).
```
  - `sh seqs_renamed_to_accession_loop.sh`

- To put the sequence names in [organism_name]|[locus_name] format. I had to do this for each file individually. If you are clever, I am sure there is a way to write it into a script.
  ```
    cat [genbank_name]_renamed1.aa.fasta | sed 's/>/>sp_name\|/g' > sp_name_penultimate_names.aa.fasta
   ```
- To make it all single line.
  - `sh awk_multi_to_single_loop.sh`
