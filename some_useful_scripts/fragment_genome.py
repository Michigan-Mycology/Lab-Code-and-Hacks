from sequence import *
from contig import *
import sys
import re
import numpy

high = 50000
low = 10000
frag_prefix = "MortGlom_Ag77"
n = 0
fragments = {}
#string = "ATCGTTCGTCTATCGTCGTAGCTAGCTAGCTAGAGAGATGGTTTTCGCTCGCTCGATCGCTAGGAGGAAGATCTCTAGCTAGGGGCTCGCTGATCGCCCAACACACAGCTAGTCGCTC"

ns = 0

allseqs = readFasta(sys.argv[1])
#print len(allseqs)

for tig in allseqs:
    string = tig.seq

    ## This block will count all of the Nx20+ delimited contig scaffolding boundaries ##
    '''
    for match in re.finditer("N{20,}",string):
        print match.group()
        print len(match.group())
    for letter in string:
        if letter == "N":
            ns+=1
    reblocks = re.finditer("N{20,}",string)
    for match in reblocks:
        ns -= len(match.group())
    #print len(string)
    '''

    while len(string) >= high:
        rand_len = numpy.random.random_integers(low,high)
        start = numpy.random.random_integers(1,len(string)-rand_len)
        new_substr = string[start:start+rand_len]
        fragments[frag_prefix+"_"+str(n)]=new_substr
        string = string[:start] + string[start+rand_len:]
        n+=1
    fragments[frag_prefix+"_"+str(n)]=string
    n+=1
    #print len(fragments)

## This block will confirm that fragmentation still accounts for total size of input genome ##
'''
total = 0
for key,sub in fragments.iteritems():
    total += len(sub)
print ns
print total
'''

## This block will output the fragments dictionary in fasta format
for key, fragment in fragments.iteritems():
    print ">"+key+"\n"+fragment
