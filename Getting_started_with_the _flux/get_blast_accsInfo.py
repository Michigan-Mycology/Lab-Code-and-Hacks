#Title: Get Blast Accessions
#Version: 1.2
#Author: Kevin Amses
#Date: 2 July 2013

import subprocess
import sys

a = open(sys.argv[1],"r")
f = a.read()
a.close()
outpath = sys.argv[2]
prime_output = open(outpath,"w").close()
lines = f.split("\n")
accessions = []
evalues = []
plateIDs = []
for x in lines:
	l = len(x)
	if l > 0:
		col = x.split("\t")
		e = col[10]
		thisID = col[0]
		acc = col[1].split("|")
		accessions.append(acc[3])
		plateIDs.append(thisID)
		evalues.append(e)
output = open(outpath,"a")
for seqID in accessions:
	output.write(seqID)
	output.write("\n")
output.close()
subprocess.call(["blastdbcmd", "-db", "nt", "-entry_batch", outpath, "-outfmt", "%S", "-out", "getaccs_temp.txt"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
temp_output = open ("getaccs_temp.txt","r")
temp_output_read = temp_output.read()
temp_output.close()
subprocess.call(["rm", "getaccs_temp.txt"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
final_output = open (outpath, "w")
namesList = temp_output_read.split("\n")
num = 0
for name in namesList:
	n = len(name)
	if n > 0:
		final_output.write(plateIDs[num])
		final_output.write("\t")
		final_output.write(accessions[num])
		final_output.write("\t")
		final_output.write(evalues[num])
		final_output.write("\t")
		final_output.write(name)
		final_output.write("\n\n")
		num=num+1
final_output.close()

	
	
	
