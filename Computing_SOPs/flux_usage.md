##James Lab flux SOP
Last updated Fall 2018

### Logging into flux
First make sure that you've talked to Tim and have an active flux account (he can get one set-up for you). Then you can login to flux using the following command:

`ssh [uniquename]@flux-login.arc-ts.umich.edu`

You'll be prompted for your UMich password and will have to have DUO setup for two-component login. You can set that up [here](https://www.safecomputing.umich.edu/two-factor-authentication).

### Getting around on and using flux

Note that you'll be logged into a BASH shell. To get around and do things, you'll need to know how to use basic BASH commands. [Here's a list to get you started](https://files.fosswire.com/2007/08/fwunixref.pdf).

It's always easier to use shell-based text editors to edit files than to edit them on your desktop and upload them to flux. I personally recommend VIM, but Nano is another great option. Both are alrady installed on flux. Check out these documentations to get started:

* [VIM cheatsheet](https://www.keycdn.com/blog/vim-commands)
* [Nano cheatsheet](https://www.codexpedia.com/text-editor/nano-text-editor-command-cheatsheet/)

There are two main directories that you'll be using to store and run things on flux:

* `/home/[uniquename]` This is permanent storage space where you can install programs that you'd like to use that aren't installed on flux or store small databases or files. **There is a limit to how much you can store here, ~100 Gb.** Installing programs on flux can be annoying and difficult, so if it's not working for you, you can contact the flux staff at [hpc-support@umich.edu](hpc-support@umich.edu) to see if they'd be open to installing it for you. They're pretty helpful.
* `/scratch/tyjames_flux/[uniquename]` This is where you can store data files that you're currently working on and running jobs with. There is no limit to the amount of data you can store here, however scratch is only meant for files that you are actively working on. For this reason, the flux staff will periodically purge old files from your scratch directory. You'll be sufficiently warned about these purges in advance, but just keep this in mind. Long term back-up for data files is located on our section of the `lsa-research01` server which is easily accessible from the Mac desktop computer in the lab.

### Using programs installed on flux
Flux is pre-loaded with tons and tons of programs for you to use to analyze data. In order to use them, you first have to "load" them into you "enviornment". This is easily done using the `module load` command. For instance:

```
module load ncbi-blast
module load spades
module load samtools
module load stacks
```

You have to know the name of the module that your program is installed under. If you don't you can seach for it:

```
>>> module spider blast
---------------------------------------------------------------------------
  ncbi-blast:
---------------------------------------------------------------------------
    Description:
      Basic Local Alignment Search Tool (BLAST) is the most widely used
      sequence similarity tool.

     Versions:
        ncbi-blast/2.2.29
        ncbi-blast/2.5.0

---------------------------------------------------------------------------
  For detailed information about a specific "ncbi-blast" module (including how to load the modules) use the module's full name.
  For example:

     $ module spider ncbi-blast/2.5.0
---------------------------------------------------------------------------

---------------------------------------------------------------------------
  rmblast: rmblast/2.2.28
---------------------------------------------------------------------------
    Description:
      RMBlast is a RepeatMasker compatible version of the standard NCBI
      BLAST suite.


    This module can be loaded directly: module load rmblast/2.2.28

    Help:
      
      RMBlast is a RepeatMasker compatible version of the standard NCBI BLAST suite. The primary difference between this distribution and the NCBI distribution is the addition of a new program 'rmblastn' for use with RepeatMasker and RepeatModeler.
```
Now you know to type `module load ncbi-blast` to load the standard BLAST package. After that command completes, you will be able to run BLAST via a PBS script submitted to the scheduler (see more on this below).

**NOTE**: You're not supposed to run long-running commands on the "head" node (ie the shell that you are logged into following `ssh [uniquename]@flux-login.arc-ts.umich.edu`. Instead, you need to submit a job, via a PBS script, to a particular allocation on flux.

### Allocations that we're allowed to use ###
* **tyjames_flux**: Our base allocation and your go-to for most jobs that you want to run on the cluster. we pay a flat rate for this every month regardless of usage, so use it! Here are the resources available to us here:

	* 24 processors (CPUs/procs)
	* 96 Gb of memory (RAM) 

* **tyjames_fluxod**: Our "on-demand" allocation. Usage of resources under this allocation cost around **3x** as much as under tyjames\_flux. So only use this allocation if our base allocation (ie tyjames\_flux) is full and you need something fast. Permission from Tim should be sought for long jobs or jobs that are going to use a significant amount of computer resources (ie CPUs or memory). Here are the resources available to us under this allocation:
	* ~Infinite processors
	* ~Infinite memory
	* **_But_, they cost a whole lot more and you'll be waiting in line with the rest of the cluser users at UM.**

* **lsa_fluxm**: This is a "high-memory" allocation that is paid for by LSA for LSA cluster users. You are **only** allowed to submit jobs that require high memory resources, such as *de novo* genome assemblies. According to the HPC folks, a high-memory job is one that requires **>80 Gb** of memory. You'll get nasty emails about violations of usage policies if you submit jobs requesting smaller memory amounts to this allocation.Here are the resources available to us under this allocation:
	* 56 processors
	* 1400 Gb memory
	* It's free, but has special resource usage policies and you'll be waiting in line.

###Checking the availability of resourses on an allocation###
When deciding how many resources to request for a particular job or set of jobs, it usually pays to see what is currently available on the cluster. If you request too much, you'll have to wait for the resources to free-up. If you request too little, your job may take longer-than-necessary to complete or crash due to insufficient resources (almost always due to memory constraint). Thankfully this is easy to do:

This first one is pretty self-explanatory. There are currently 11/24 of our allocated processors using 50/96 Gb of memory, leaving 13/24 processors and 46/96 Gb of memory available for new jobs. 

```
>>> freealloc tyjames_flux
11 of 24 cores in use, 13 cores available 
50 GB of 96 GB memory in use, 46 GB memory available 
```
-----

This second output is a little more involved. You can actually see the individual active jobs running and the number of processors that they're using. By looking at the `PROCS` column, you can see where the `11 of 24 cores in use` from the previous command came from (2+3+3+3 = 11). Note that you can't see the used/available memory below. 

If your waiting in line to use the allocation, your job will be visible a couple minutes after submission in the `eligible jobs` section. If there is something wrong with your PBS script (requiring correction) it will be visible in the `blocked jobs` section. If your job stays here for awhile, cancel it and look for errors you made in your PBS script.

```
>>> showq -w acct=tyjames_flux
active jobs------------------------
JOBID              USERNAME      STATE PROCS   REMAINING            STARTTIME

32264217           abelasen    Running     2  2:08:49:24  Tue Dec  4 15:02:27
32267189             amsesk    Running     3  8:06:50:25  Tue Dec  4 17:03:28
32267190             amsesk    Running     3  8:06:50:25  Tue Dec  4 17:03:28
32267191             amsesk    Running     3  8:06:50:25  Tue Dec  4 17:03:28

4 active jobs          11 of 19144 processors in use by local jobs (0.06%)
                       834 of 1134 nodes active      (73.54%)

eligible jobs----------------------
JOBID              USERNAME      STATE PROCS     WCLIMIT            QUEUETIME


0 eligible jobs   

blocked jobs-----------------------
JOBID              USERNAME      STATE PROCS     WCLIMIT            QUEUETIME


0 blocked jobs   

Total jobs:  4

```

### PBS Scripts - The Header ###

PBS scripts are what we use to schedule jobs and request the particular amount of resources we need for our jobs to complete. All PBS scripts consist of a header section that occurs at the top of the file, each line of which is preceded by a `#`. Each line specifies a certain job characteristic (eg name, logfile, resrouces requiremented etc). Here's a working example:

```
#PBS -N my_job_name
#PBS -V
#PBS -A tyjames_flux
#PBS -l qos=flux
#PBS -q flux
#PBS -l nodes=1:ppn=3,mem=6gb,walltime=200:00:00
#PBS -M amsesk@umich.edu
#PBS -m abe
#PBS -j oe
``` 

**Option Explanation**

* `-N` specifies the name of your job. Note that only the first 13 characters will be recognized by the job scheduler.
* `-V` tells the scheduler to load any modules currently loaded in you environment when starting the job (more on this later).
* `-A`, `-l qos`, and `-q` are important in letting the scheduler know which allocation you would like your job run on. This is important for our purporses in this section. In the context of this particular job, `my_job_name`, you can see that I want it to run on the `tyjames_flux` allocation from this line:
	
	`#PBS -A tyjames_flux`
	
	If I wanted to instead run this job on the `tyjames_fluxod` allocation, this block of code would instead look like this:
	
	```
	#PBS -A tyjames_fluxod
	#PBS -l qos=flux
	#PBS -q fluxod
	```
	
	Note that both the `-A` and `-q` option fields changed here, but the `-l` field remains `qos=flux`. For all of our current purposes in the lab, `qos` **ALWAYS** equals `flux`, no matter which of the three allocations we have access to you are sending you job to run on. 
	
	Finally, here's how the block would change for a job scheduled on `lsa_fluxm`:
	
	```
	#PBS -A lsa_fluxm
	#PBS -l qos=flux
	#PBS -q fluxm
	```
* `-l nodes=,etc..` is where you specify the resource requirements of your job. Remember that we already specified the `-l` option above. This is because `-l` specifies a variety of options that I like to split for clarity.

	In this particular line I am asking for 1 node (equivalent to "computer" with `nodes=1`. On that particular node, I want there to be (i) 3 CPUs (or processors) with (ii) 6gb of memory split between those 3 processors running for (iii) 200 hours.
	
	`nodes=1:ppn=3,mem=6gb,walltime=200:00:00`
	
	**Some important things to be aware of:**
	
	* There are a couple of different ways to specify the number of processors, and their relationship to eachother, that you want for a job:
		* `nodes=1:ppn=X` requires that your X processors are on the same machine, or node.
		* `procs=X` doesn't requres that your X processors are on the same machine or node.
		* Exchanging processing information between processors on different machines (ie MPI) requires special code be incorporated into the prorgram you're running. 
		* **So when in doubt**, use `nodes=1:ppn=X`.
	* You'll sometimes see memory specified as either `pmem=Xgb` or `mem=Xgb`. The only difference here is that `pmem` specifies the amount of memory to give to each processor you request, while `mem` specified to total memory to be split between your requested processors. So...
	
		`nodes=1:ppn=3,mem=6` is equivalent to `nodes=1:ppn3,pmem=2`
	* Walltime is specified in the format `dd:hh:mm:ss` or `hh:mm:ss` or `mm:ss` or whatever denomination you want to include in that order. I always specify **MORE** walltime than I think I need. Otherwise my job may run out of time before it's finished, and then you have to start over in most cases. Note that larger walltimes will cause you tot experience longer wait times in the public allocations.

* The final three header lines are all about notifications and error reporting.
	`-M amsesk@umich.edu` tells the scheduler to notify me via my email when things happen.
	`-m abe` defines what I want to know about via email. In this case when my job (a)borts, (b)egins, and (e)nds.
	`-j oe` tells the scheduler to send the output and error information to a single `*.o[JobNumber]` file. You'll start to find these all over the place. It's a good place to look for why your job terminated, what it said while it was running, etc.
	
### PBS Scripts - The Body
The body of the PBS scripts is literally just a list of commands to run once the job starts just as if you were you typing them into the flux-login shell. So just figure out which commands you want to run, the options you want to run them with, etc. and enter them here (without the leading `#`!)

So for instance, if I wanted to BLAST a nucleotide file against the NCBI nucleotide database, my PBS script could look like this:

```
#PBS -N my_blastn_job
#PBS -V
#PBS -A tyjames_flux
#PBS -l qos=flux
#PBS -q flux
#PBS -l nodes=1:ppn=3,mem=6gb,walltime=200:00:00
#PBS -M amsesk@umich.edu
#PBS -m abe
#PBS -j oe

module load ncbi-blast
cd /scratch/tyjames_flux/amsesk/rhizopus/discard/blastn

blastn -query ../contig.fastas/XY01851_contigs.clip.500.fasta -outfmt 6 -num_threads 3 -out XY01851_blastn.out -max_target_seqs 1 -db nt
```

Easy as that.

### Submitting your Job
Once your PBS script looks good, you can submit it via the command `qsub`

```
>>> qsub my_pbs_script.pbs
32270190.nyx.arc-ts.umich.edu
```

The number before the first dot above is your job number. If there's something wrong with the format of your PBS script, or if you forget to specify a required option, you'll get an error message instead.

You can now check the status of your job(s) in the queue my using

`qstat -u [uniquename]`

or 

`freealloc [allocation]`

or

`showq -w acct=[allocation]`

as described above.

### Some Notes on Multiprocessing (requesting multiple processors)

Please note that: **just because you specify a large number of processors for your job to run with DOES NOT mean that it will actually be using all of them.**

Very few programs will attempt to "sense" how many processors are available for it to use. So if you're not telling or able to tell you program how many processors to use, it's likely only using **one**!

What this means is that if you request a bunch of processors for a job that's only using once, you're either taking up resources that aren't doing anything and aren't available to other job submitters (`lsa_fluxm` and `tyjames_flux`) or you're **paying** for processors to stay idle (`tyjames_fluxod`). Don't do it!

The only way to know whether or not your program is capable of using multiple processors is to consult the program's help screen. Number of processors for a command to use is almost always explicitly specified as a command line option.

For instance, here's a line from the `blastn` help screen, accessed by typing `blastn -help`:

```
 -num_threads <Integer, >=1>
   Number of threads (CPUs) to use in the BLAST search
   Default = `1'
    * Incompatible with:  remote
```

Seeing something like this in the help screen lets us know that we can tell `blastn` to use multiple processors. Looking back at the example PBS script above, you can see where I explicitly specified this option to be equal to the number of processors that I requested for my job (`-num_threads 3`):

```
blastn -query ../contig.fastas/XY01851_contigs.clip.500.fasta \
-outfmt 6 -num_threads 3 -out XY01851_blastn.out -max_target_seqs 1 \
-db nt
```

If you're not specifying an option like this in your call to your program, it's safe to assume that it's not using multiple processors. Here's another example of a command-line option specifying the number of processors to use from the `spades` help screen:

```
-t/--threads	<int>		number of threads
				[default: 16]
```

Note that in this example the default is 16 processors, so you could get away without specifying this option **if** you requested 16 processors for your job. Otherwise, spades either thinks it has more or less processors available to it than it really does.

**So, always specify an option for threads when noted in the program's help screen and write your PBS script to match.** Otherwise, assume that it's only using one processor, and request resources as such. If you don't do this, your taking up or paying for resources that you don't need and aren't actaully using. This is going to slow everyone else down and cost us extra money. Ask someone if you have questions.

### The Same Goes for Memory
With programs that can require large amounts of memory (eg `spades`, `ESOM`), there is usually an option for specifying the amount of memory the program should assume it has available to use. From the `spades` help screen:

```
-m/--memory	<int>		RAM limit for SPAdes in Gb (terminates if exceeded)
				[default: 250]
```

Spades will crash if it runs out and you'll have to start over. Make sure you what you set that limit as in your call to `spades` and the amount you requested in your PBS script match.
	

	

	
