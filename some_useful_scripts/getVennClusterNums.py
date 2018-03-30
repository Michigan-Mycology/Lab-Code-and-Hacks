#Written by Kevin Amses (amsesk@umich.edu)

import sys
import itertools
import subprocess

if sys.argv[1] in ['-h','-help']:
    print "Usage -- python getVennCluserNums.py [taxaIDfile] [fastortho.end] [Key?(True|False)]"
    sys.exit()

def getVennClusterNums(taxafile,fastorthoOut,keys="False"):
    taxaIDs=open(taxafile).readlines()
    commandsRun=open(sys.argv[1]+".commandsRun",'w')
    #print taxaIDs
    if keys=="True":
        print "The key you provided:"
        print "-------------------------------------------------"
        print open(taxafile).read()
        keyed={}
        for idx,i in enumerate(taxaIDs):
            keyed[i.split("\t")[0]]=i.split("\t")[1].strip()
            taxaIDs[idx]=i.split("\t")[0]
    combos=[]
    vennOut={}
    #generate the combinations
    for i in range(len(taxaIDs)):
        combos = combos + list(itertools.combinations(taxaIDs,i+1))
    #make a bash command that selectively grep's and grep -v's for each combination put into combos
    #print taxaIDs
    #print len(combos)
    for tup in combos:
       # print "Combo: "+str(tup)
        names=""
        keylabel=""
        outBash="cat "+fastorthoOut
        for y in taxaIDs:
            y=y
            #print "Y: "+y
            outBash+=" | "
            if len(y.split(",")) == 1:
                if y not in tup:
                    outBash+="grep -v \("+y.strip()+"\)"
                    #print "Nope"
                elif y in tup:
                    #print "Yup"
                    names+=y.strip()+","
                    if keys == "True":
                        keylabel+=keyed[y.strip()]
                    outBash += "grep \("+y.strip()+"\)"
            elif len(y.split(",")) > 1:
                if y not in tup:
                    #print "Nope"
                    pos=1
                    for x in y.split(","):
                        outBash+="grep -v \("+x.strip()+"\)"
                        if pos < len(y.split(",")):
                            outBash+=" | "
                        pos+=1
                elif y in tup:
                    #print "Yup"
                    outBash+="grep -e '"
                    pos=1
                    for x in y.split(","):
                        outBash+="\("+x.strip()+"\)"
                        if pos < len(y.split(",")):
                            outBash+="\|"
                        pos+=1
                    outBash+="'"
                    names+=y.strip()+","
                    if keys == "True":
                        if keyed[y.strip()] not in keylabel:
                            keylabel+=keyed[y.strip()]
        outBash+=" | wc -l"
        #print outBash
        p = subprocess.Popen(outBash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)
        out, err = p.communicate()
        #print err
        if keys == "True":
            names+= "["+''.join(sorted(keylabel))+"]"
            commandsRun.write("["+''.join(sorted(keylabel))+"]\t"+outBash+"\n\n")
        else:
            commandsRun.write(outBash+"\n\n")
        vennOut[names]=out.strip()
    #print vennOut
    #print len(vennOut)
    tot=0
    print "RESULTS"
    print "-------------------------------------------------"
    for idx,num in vennOut.items():
        print str(idx) + " : " + str(num)
        tot += int(num)
    print "\nGrouped "+str(tot)+" total orthologous clusters."
    print "Generated "+str(len(vennOut))+" total categories for your venn diagram."

getVennClusterNums(sys.argv[1],sys.argv[2],sys.argv[3])

