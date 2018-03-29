import sys
import re
from sequence import *
import subprocess

if sys.argv[1] == "-help":
    print "USAGE: parseBlastOutput.py [lib] [blast output] > output_file"
    sys.exit()

'''
cmd = "grep \> "+sys.argv[1]+" | sed 's/>//'"
s = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
out,err = s.communicate()
lib_headers = out.split("\n")
ids = {}
for i in lib_headers:
    if i.split("|")[0] == "spex" or i.split("|")[0] == "spexex":
        acc = i.split(" ",1)[0]
        desc = i.split(" ",1)[1]
        ids[acc] = desc
    else:
        print "ERROR: Reformat your database headers."

#print lib
'''
#''' read in the whole fasta file
lib = readFasta(sys.argv[1],seq_type="prot",contig_info=False)
ids = {}
for i in lib:
    if i.label.split("|")[0] == "spex" or i.label.split("|")[0] == "spexex":
        acc = i.label.split(" ",1)[0]
        desc = i.label.split(" ",1)[1]
        ids[acc] = desc
    else:
        print "ERROR: Reformat your database headers."
#'''

#print ids
#hits = []
#labels = open("labels.txt",'w')
labels={}
for line in open(sys.argv[2]).readlines():
    #print line.split("\t")[1]
    link = line.split("\t")[1]
    contig = line.split("\t")[0]
    evalue = line.split("\t")[10]
    #print link,contig,evalue
    if link in ids.keys():
        print contig+"\t"+link+"\t"+ids[link]+"\t"+evalue

        #for i in lib:
        #    if len(i.label.split("#")) == 3:
        #        if line.split("\t")[1].strip() == i.label.split("-")[0].strip():
        #            if i.label.split("-")[0].strip() not in labels.keys():
        #                labels[ids[i.label.split("-")[0].strip()]] = i.label.strip()
#for i in hits:
#    print i


#From countMEROPS, no need to count them at this time
'''
output = open(sys.argv[3], 'w')
counts = {}
for fam in hits:
	if fam not in counts:
		counts[fam]=1
	elif fam in counts:
		counts[fam]+=1
for x in counts:
	strout = x + "," + str(counts[x]) + "\n"
	output.write(strout)
'''

#out2=open("labels_Artoli.txt",'w')
#for key,i in labels.iteritems():
#    out2.write(key+" -> "+i+"\n")

