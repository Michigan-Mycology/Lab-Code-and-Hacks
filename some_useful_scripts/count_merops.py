import sys
import os
import re
import pandas as pd
import numpy as np
from sequence import *
import cPickle as pickle
from lib import *

list_dir = os.path.abspath(sys.argv[1])
outputs_dir = os.path.abspath(sys.argv[2])
lib = os.path.abspath(sys.argv[3])

## Read in the MEROPS library and put pertinent information into a dictionary
lib = pkl_fasta_in_out(lib,seq_type="prot",contig_info=False)
ids = {}
for i in lib:
    spl = i.label.split("#")
    merops_id = re.search('^([A-Z0-9]+)[ ][-]',i.label)
    merops_id = merops_id.group(1)
    protease_fam = re.search('[#]([0-9A-Za-z]+)[#]',i.label)
    if protease_fam is not None:
        protease_fam = protease_fam.group(1)
        ids[merops_id] = protease_fam
    else:
        print "Error reading label for",i.label.split('-')[0],"...please check the format of the header."
## Count the families that occur in all the files in list dir
counts = {}
fams = {}
for i in os.listdir(list_dir):
    if os.path.isdir(os.path.join(list_dir,i)):
        continue #skip directories
    p = re.search("([a-zA-Z0-9]+)", i)
    short_name = p.group(1)
    path_to_file = os.path.join(outputs_dir,short_name+"_functional_annotation_out",short_name+".pepunit.out")
    if os.path.isdir(os.path.split(path_to_file)[0]):
        counts[short_name] = {}
        for l in open(path_to_file).readlines():
            tspl = l.split("\t")
            merops_id = tspl[1]
            aln_start = tspl[6]
            aln_end = tspl[7]
            fams[tspl[0]] = [ids[merops_id],aln_start,aln_end]
            #print ids[merops_id]
            if ids[merops_id] in counts[short_name].keys():
                counts[short_name][ids[merops_id]] += 1
            else:
                counts[short_name][ids[merops_id]] = 1
    else:
        print "Missing an output directory for "+i+"."

'''
fams_table = pd.DataFrame(data=fams)
print fams_table.head
fams_table = fams_table.transpose()
fams_table.to_csv("prot_fams.csv")
'''
#'''
table = pd.DataFrame(data=counts)
table = table.fillna(0)
table.to_csv("merops_counts.csv")
print table.head
#'''
