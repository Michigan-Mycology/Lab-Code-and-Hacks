# From Raw Reads to Genomics
###### A story by Kevin Amses
***
##### You're going to need a grealakes login#####
* ask Tim about this if you don't have one yet
* which operating system are you using
  * Windows -> PuTTY terminal emulator, [setup instructions](https://arc-ts.umich.edu/greatlakes/user-guide/)
  * Mac -> Unix Terminal
  * Linux -> Unix Terminal
* Logging in:
  * Server: greatlakes.arc-ts.umich.edu
  * Username: [Umich uniqname]
  * Password: [Umich password]
* Getting around and doing things:
  * Use the GreatLakes cheatsheet that was handed out in lab meeting as a reference for basic Unix commands and job submission with Slurm
  * Decide on a text editor. Most people use [nano](https://www.howtogeek.com/howto/42980/the-beginners-guide-to-nano-the-linux-command-line-text-editor/) [vim](https://opensource.com/article/19/3/getting-started-vim)
  * Or ask one of us!
  * When in doubt, `[program] -h` or `[program] --help` (e.g., `spades.py -help`
  * You should get two particular scripts from our server before starting `remove_small_contigs.pl` and `assemblathon_stats.pl`. I can give these to you, so just ask.

##### QC and Trimming
* Unzip read files

```
gzip -d [filename]
```

* Fastqc (I think you said you already had this done?

On the login node
```
module load Bioinformatics fastqc
fastqc [filename]
```

On a compute node (`myjob.sh`)

```
#!/bin/bash
#SBATCH --job-name fastqc
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=1g
#SBATCH --time=15:00:00
#SBATCH --account=lsa
#SBATCH --partition=standard
#SBATCH --mail-type=BEGIN,END

cd /scratch/lsa_root/lsa/kseto/raw.reads

fastqc [forward_readfile]
fastqc [reverse_readile]
```

`sbatch myjob.sh` <- submits the job

`squeue -u kseto` <- show you your current jobs


* [Trimmomatic](http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf) or [cutadapt](https://cutadapt.readthedocs.io/en/stable/guide.html) (both already on greatlakes)
  
  ```
  module load Bioinformatics trimmomatic
  module load Bioinformatics cutadapt
  ```
  
* Example `trimmomatic` Batch Script
  

```bash
### Slurm header stuff goes up here ###

module load Bioinformatics trimmomatic

cd /scratch/tyjames_flux/amsesk/rhop_neo/raw.data/combined_renamed

java -jar /home/amsesk/trimmomatic-0.36/trimmomatic-0.36.jar PE \
-threads 4 -trimlog log.txt /scratch/tyjames_flux/amsesk/\
rhop_neo/raw.data/combined_renamed/Neo1_R1.fastq /scratch/\
tyjames_flux/amsesk/rhop_neo/raw.data/combined_renamed/\
Neo1_R2.fastq ../adaptTrimmomatic/\
Neo1_forward_trimmed_paired.fastq ../adaptTrimmomatic/\
Neo1_forward_trimmed_orphan.fastq ../adaptTrimmomatic/\
Neo1_reverse_trimmed_paired.fastq ../adaptTrimmomatic/\
Neo1_reverse_trimmed_orphan.fastq ILLUMINACLIP:/home/amsesk/\
trimmomatic-0.36/adapters/NexteraPE-PE.fa:3:30:10
```

* Example `cutadapt` batch script (for NEBNext kit, apprently the TruSeq adapters too???) [see discussion of this here](https://www.biostars.org/p/149301/)

```
#!/bin/bash
#SBATCH --job-name cutadapt
#SBATCH --nodes=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=1g
#SBATCH --time=15:00:00
#SBATCH --account=lsa
#SBATCH --partition=standard
#SBATCH --mail-type=BEGIN,END

module load Bioinformatics cutadapt
cutadapt -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT -o trimmed.R1.fastq.gz -a 4 -p trimmed.R2.fastq.gz reads.R1.fastq.gz reads.R2.fastq.gz
```

##### *de novo* Genome Assembly

* After trimming, it's time to assemble our short reads into contigs, representative of larger regions of the genome sequence. Since we don't have a reference genome, this is called *de novo* assembly. We're going to try to piece the thing together by aligning reads to eachother, making bigger and bigger contigs
* Use `SPAdes` (also already on greatlakes) - this can take awhile; [the manual](http://cab.spbu.ru/files/release3.12.0/manual.html)

```module load Bioinformatics spades```

* Example SPAdes Batch Script

```
#!/bin/bash
#SBATCH --job-name=round1_spades
#SBATCH --mail-type=BEGIN,END
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=36
#SBATCH --mem-per-cpu=5g
#SBATCH --time=150:00:00
#SBATCH --account=tyjames
#SBATCH --partition=standard

module load Bioinformatics spades

cd /scratch/tyjames_root/tyjames/amsesk/scgid_pub/mock/round2

spades.py --sc --pe1-1 forward_reads.fastq --pe1-2 \
reverse_reads.fastq -m 180 -t 36 -o assembly \
-k 21,33,55,77,99 --phred-offset 33
```
This step can take awhile and depending on the size of your data, you might need to use one of the large memory computing nodes. But try it on a regular node first.

**Note** Check the `SPAdes` output directory once the job is finished. If you have a `contigs.fasta` file in there, then it worked!

Get assembly statistics by running:

```
perl /path/to/assemblathon_stats.pl contigs.fasta
```

This will print out a bunch of information about your assembly. Thinking like the number of contigs, cumulative length, GC content, etc. Check the N50 value to decide what your size cutoff should be for removing small contigs. For instance if my N50 is 1000 bp, I shouldn't be cutting off at 3000 bp - I would be tossing out tons of data.

Once you've decided:

```
perl /path/to/remove_small_contigs.pl [bp_cutoff] contigs.fasta > contigs.clip.[bp_cutoff].fasta
```

e.g.,

```
perl /path/to/remove_small_contigs.pl 500 contigs.fasta > contigs.clip.500.fasta
```

Ok, so now you have an draft genome assembly from your sequencing libraries. The path from here is a bit up to you depending on what you want to do. You can check for contamination and potentially refine your assembly using contamination removal techniques. There are a lot of these. Once you're happy with your assembly, you can continue on annotate and characterize it in  various ways.

***...This is a work in progress...***

