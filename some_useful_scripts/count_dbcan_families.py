import sys
import os
import re
import pandas as pd
import numpy as np

list_dir = os.path.abspath(sys.argv[1])
outputs_dir = os.path.abspath(sys.argv[2])

counts = {}

for i in os.listdir(list_dir):
    if os.path.isdir(os.path.join(list_dir,i)):
        continue
    p = re.search("([a-zA-Z0-9]+)", i)
    short_name = p.group(1)
    path_to_file = os.path.join(outputs_dir,short_name+"_functional_annotation_out",short_name+".dbcan.dm.out.parsed")
    if os.path.isdir(os.path.split(path_to_file)[0]):
        counts[short_name] = {}
        for l in open(path_to_file):
            fam = l.split('\t')[0].split('.')[0]
            if fam in counts[short_name]:
                counts[short_name][fam] += 1
            else:
                counts[short_name][fam] = 1

table = pd.DataFrame(data=counts)
table = table.fillna(0)
table.to_csv("cazy_counts.csv")
print table.head

'''
if sys.argv[1] == "-help":
    print "countCazyFams.py [.dm.ps output file] [output]"
    sys.exit()

tspl = []
cazys = []
for row in open(sys.argv[1]).readlines():
	tspl.append(row.split('\t')[0])
for model in tspl:
		cazys.append(model.split('.')[0])
counts = {}
output = open(sys.argv[2], 'w')
for fam in cazys:
	if fam not in counts:
		counts[fam]=1
	elif fam in counts:
		counts[fam]+=1
for x in counts:
	strout = x + "," + str(counts[x]) + "\n"
	output.write(strout)
'''
