## Quick and dirty way of getting data from the SRA
You will need to know the acession numbers for the data you want to use. I will be using the Olpidium genome as an example.

For single files on the command line:

`wget ftp://ftp-trace.ncbi.nih.gov/sra-sra-instant/reads/ByRun/sra/{SRR|ERR|DRR}/<first 6 characters of accession>/<accession>/<accession>.sra`

For example, using the Olpidium genome:

`wget ftp://ftp-trace.ncbi.nih.gov/sra-sra-instant/reads/ByRun/sra/SRR/SRR420/SRR420852/SRR420852.sra`

This will download individual Illumina runs. If you have many runs that you want to download, it would be faster to use the `prefetch` tool in the sratool kit. For this, you will need to use ncbi to generate an accession list. Seach the SRA on the ncbi website for the datasets you want. Using Olpidium as an example:

Go to https://www.ncbi.nlm.nih.gov/

In the drop down menu near the top left, select "SRA"

Type "Olpidium" into the search field and hit search.

Select all of the dataset you want to include.

Under the "Send to:" drop down menu, select "File". This will cause a second drop down menu labelled "Format" to appear. Select "Accession List".

Save the file to your hard drive and then upload it to the flux.

Load the sratoolkit on the flux:

`module load sratoolkit`

This will load sratoolkit/2.8.2-1. There is an older version should you need it.

Call the "prefectch" program load the files:

`prefetch --option-file SraAccList.txt`

Now, the files are NOT in a usable format. You have to generate fastq files from the .sra files using "fastq-dump". 

**IMPORTANT NOTE:** The exact options you use with "fastq-dump" will depend on what the format the raw data was in, i.e., paired-end versus single-end.

The Olpidium data is paired-end Illumina data.

`fastq-dump -split-files SRR420852.sra`

If you need help, there is online documentation:

https://www.ncbi.nlm.nih.gov/books/NBK158899/

https://www.ncbi.nlm.nih.gov/sra/docs/
