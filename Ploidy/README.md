__kmercountexact.sh__  This is an example SLURM batch script that you can use to generate kmer histogram and peak files. You can visualize them using the provided python script (kmer_histograms.py)

__kmer_histograms.py__ This script will pop-out PDFs of kmer histograms generated with the khist and peak files generated by `kmercountexact.sh,` but you need to intall some python packages to use it. Here's how:

```
# Run this on greatlakes
# Load the Anaconda python3.7 module that is centrally installed on greatlakes
module load python3.7-anaconda

# It's easiest to manage python dependencies in virtual environments, so let's set one up now.
cd ~
python -m venv <NAME_YOUR_VIRTUAL_ENVIRONMENT>

# Now turn on your new virtual environment (You have to type this in on each new login before you want to run a script that depends on your virtual environment
source ~/<NAME_OF_YOUR_VIRTUAL_ENVIRONMENT>/bin/activate

# Install the packages kmer_histograms.py depends on.
pip install plotly

# Test that you can run scripts
python kmer_histograms.py -h
```

Here's what you should see:

```
usage: kmer_histograms.py [-h] -k khist_file -p peaks_file

optional arguments:
  -h, --help            show this help message and exit

required named arguments:
  -k khist_file, --khist khist_file
                        khist file from kmercountexact.sh
  -p peaks_file, --peaks peaks_file
                        peaks file from kmercountexact.sh
```

Okay, now you can run the script like so:
```
python kmer_historgrams.py -k <khist_file> -p <peaks_file>
```

To exit out of the virtual environment, just type `deactivate`
