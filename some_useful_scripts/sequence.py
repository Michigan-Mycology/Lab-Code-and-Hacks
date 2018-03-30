import sys
import numpy

def reverse (string):
    chars = ["x"]*len(string)
    pos = len(string) - 1
    for l in string:
        chars[pos] = l
        pos -= 1
    return ''.join(chars)
class sequence():
    def __init__(self, label, seq, seq_type = "nucl", contig_info = False):
        if seq_type == "prot" and contig_info == True:
            self.coverage = float(".".join(label.split("_")[5].split(".")[0:len(label.split("_")[5].split("."))-1]))
        elif seq_type == "nucl" and contig_info == True:
            self.coverage = float(label.split("_")[5])
        elif seq_type == "nucl" or seq_type == "prot" and contig_info == False:
            self.coverage = "n/a"
        if contig_info == True:
            self.name = label.split("_")[0]+"_"+label.split("_")[1]
        self.sequence = seq.strip()
        self.length = len(self.sequence.strip())
        self.label = label
        self.nr_domain = ""
        self.nr_phylum = ""
        if seq_type is "nucl":
            self.gc = float()
            self.gcCount = 0
            for letter in self.sequence:
                if letter == "G" or letter == "C":
                    self.gcCount += 1
                self.gc = float(self.gcCount)/float(self.length)
    def outFasta(self):
        out= ">" + self.label + "\n"+ self.sequence
        return out
    def revcomp(self):
        comp=""
        for i in self.sequence:
            if i == "A":
                comp+="T"
            elif i == "T":
                comp+="A"
            elif i == "C":
                comp+="G"
            elif i == "G":
                comp+="C"
        out = reverse(comp)
        return out

def revcomp_str(dna_string):
    comp=""
    for i in dna_string:
        if i == "A":
            comp+="T"
        elif i == "T":
            comp+="A"
        elif i == "C":
            comp+="G"
        elif i == "G":
            comp+="C"
    out = reverse(comp)
    return out
#read sequences in a fasta file into individual sequence() objects
def readFastq(infile):
    allSeqs=[]
    lengths=[]
    p=1
    m=0
    for i in open(infile).readlines():
        if m == 100:
            break
        if p == 2:
            lengths.append(len(i.strip()))
        if p == 4:
            p = 0
        p+=1
        m+=1
        #print i.split("\n")[1]
        #print "XXXXXXX"
        #p+=1
    return numpy.mean(lengths)

def readFasta(file, seq_type = "nucl", contig_info = False):
    allSeqs=[]
    for i in open(file).read().split(">"):
        if len(i) == 0:
            continue
        l=0
        seq=""
        #print i
        for x in i.split("\n"):
            if l==0:
                lab=x
            elif l!=0:
                seq+=x
            l+=1
        if seq_type == "prot" and contig_info == True:
            allSeqs.append(sequence(lab,seq,"prot",True))
        elif seq_type == "nucl" and contig_info == True:
            allSeqs.append(sequence(lab,seq,"nucl",True))
        elif seq_type == "prot" and contig_info == False:
            allSeqs.append(sequence(lab,seq,"prot",False))
        elif seq_type == "nucl" and contig_info == False:
            allSeqs.append(sequence(lab,seq,"nucl",False))
            #allSeqs.append(contig(lab,seq))
    return allSeqs

def get_attribute_list (instanceList, attribute,contigMode=True):
    assert isinstance(instanceList,list), "Argument instanceList must be a list."
    if contigMode == True:
        assert any(isinstance(x,contig) for x in instanceList), "Argument instanceList must be a list of contig() instances. FYI: contigMode is ON"
    else:
        assert any(isinstance(x,sequence) for x in instanceList), "Argument instanceList must be a list of sequences() instances. FYI: contigMode is OFF"
    listToOutput = []
    for i in instanceList:
        listToOutput.append(getattr(i,attribute))
    return listToOutput
#for i in readFasta(sys.argv[1]):
 #   print i.outRevComp()


