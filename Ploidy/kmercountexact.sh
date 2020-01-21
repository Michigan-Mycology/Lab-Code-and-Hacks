#!/bin/bash
#SBATCH --job-name=kmerc
#SBATCH --mail-type=BEGIN,END
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=25g
#SBATCH --time=4:00:00
#SBATCH --account=tyjames1
#SBATCH --partition=standard

# kmercountexact.sh is provided with BBTools from the JGI. Download it here: https://sourceforge.net/projects/bbmap/ 
# Here's an example of how to run it. 
# It can need a significant amount of memory, but runs really quickly.
# The files we're interested in are the peaks and khist files that you specify in the command

kmercountexact.sh in=../reads/69521_TACGCTGC-TCGACTAG_S30_L005_R1_001.fastq in2=../reads/69521_TACGCTGC-TCGACTAG_S30_L005_R2_001.fastq k=23 khist=69521_23.khist peaks=69521_23.peaks threads=4 -Xmx78g 
