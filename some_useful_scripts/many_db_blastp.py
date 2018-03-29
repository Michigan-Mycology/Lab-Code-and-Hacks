### Use this script to blast a set of sequences against many blast databases in a directory ###

import sys
import os
from sequence import *
import subprocess

if sys.argv[1] in ['-h','--help']:
    print "USAGE: python many_db_blastp.py [query_fasta] [db_directory] [output directory]"
    sys.exit()

fasta = os.path.abspath(sys.argv[1])
dbdir = os.path.abspath(sys.argv[2])
outdir = os.path.abspath(sys.argv[3])

dbs = []
for i in os.listdir(dbdir):
    if i.split('.')[0] not in dbs:
        dbs.append(i.split('.')[0])

os.chdir(outdir)
try:
    os.mkdir(os.path.basename(fasta)+'_as_query')
except:
    pass
os.chdir(os.path.basename(fasta)+'_as_query')

queries = readFasta(fasta,seq_type='prot',contig_info=False)

for query in queries:
    with open('query_temp.fasta','w') as f:
        f.write(query.outFasta())
    for db in dbs:
        args = ['blastp', '-query', 'query_temp.fasta', '-evalue', '1e-10', '-max_target_seqs', '1', '-db', os.path.join(dbdir,db), '-outfmt', '6']
        p = subprocess.Popen(args,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        out,err = p.communicate()
        with open(query.label+'.blast.out','a') as output:
            output.write(out)
    os.remove('query_temp.fasta')
