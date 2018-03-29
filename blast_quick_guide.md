You can download blast to run locally [here](https://blast.ncbi.nlm.nih.gov/Blast.cgi?CMD=Web&PAGE_TYPE=BlastDocs&DOC_TYPE=Download) and NCBI has decent, albeit tr;dl, documentation in the form of two books: [Blast Help}(https://www.ncbi.nlm.nih.gov/books/NBK1762/) and [Blast User Manual](https://www.ncbi.nlm.nih.gov/books/NBK279690/).

To build a custom database use `makeblastdb`.

``makeblastdb -in [fasta file with your sequences] -dbtype [nucl or prot] -out [name of database]``

To get only the aligned sequences returned, use the [instructions kindly provided here](https://www.biostars.org/p/222341/).

Run your blastn/p search.
``blastn -task megablast -query [your query sequence(s)] -evalue 1e-10 -db [whatever database you are using] -out [output name] -outfmt '6 std sseq'``

Then retrieve the sequences.

``cut -f 2,13 [blast output] | awk '{printf(">%s\n%s\n", $1, $2); }' > blastout.aligned.fasta``
