import sys
import os
import re
import pandas as pd
import numpy as np
from sequence import *
import cPickle as pickle

def pickle_loader (pklFile):
    try:
        while True:
            yield pickle.load(pklFile)
    except EOFError:
            pass

def pkl_fasta_in_out (path, seq_type = "nucl", contig_info = True):
    pkl_path = path+".pkl"
    #print pkl_path
    if os.path.isfile(pkl_path):
        objlist = []
        with open(pkl_path,'r') as input:
            for seq in pickle_loader(input):
                objlist.append(seq)
    else:
        objlist = readFasta(path, seq_type, contig_info)
        with open(pkl_path,'w') as output:
            for seq in objlist:
                pickle.dump(seq, output, pickle.HIGHEST_PROTOCOL)
    return objlist

def get_sequence_range (seq_obj, start, end):
    return seq_obj.sequence[start:end+1]

def newline_to_csv (f):
    ele = []
    for line in open(f).readlines():
        ele.append('"'+line.strip()+'"')
    return ','.join(ele)

