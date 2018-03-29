from sequence import *
import sys
import cPickle as pickle
from lib import *

wanted = open(sys.argv[1]).readlines()
#wanted = [x.strip().split(",") for x in wanted]
toget = {}
for i in wanted:
    spl = i.strip().split(",")
    toget[spl[0]] = [int(spl[1]),int(spl[2])]
allseqs = pkl_fasta_in_out(sys.argv[2],seq_type="nucl",contig_info=False)

for seq in allseqs:
    label_space_trunc = seq.label.split(" ")[0] ## gets around issue where label is truncated at space
    if label_space_trunc in toget.keys():
        seq.sequence = seq.sequence[toget[label_space_trunc][0]:toget[label_space_trunc][1]+1]
        seq.label = seq.label.split(' ')[0]
        print seq.outFasta()
'''
for seq in allseqs:
    if seq.label.split(" ")[0] in toget:
        print tig.outFasta()
'''
