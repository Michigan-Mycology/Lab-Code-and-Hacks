from sequence import *
import sys
import cPickle as pickle
from lib import *

wanted = open(sys.argv[1]).readlines()
wanted = [x.strip() for x in wanted]

allseqs = pkl_fasta_in_out(sys.argv[2],seq_type="nucl",contig_info=False)

out = [x for x in allseqs if x.label.split(" ")[0] in wanted]
for i in out:
    print i.outFasta()

