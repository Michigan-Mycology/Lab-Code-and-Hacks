import sys
import os
import re
from scgid.sequence import readFasta, Sequence
class Tests(object):
    def __init__(self):
        self.tests = {
                "AlnFiltSize": False,
                "AlnFiltContent": False,
                }
    def remove_correct_taxa(self):
        aln = list()
        bm = {331:["Seq2","Seq3"]}
        basename = "Foo"
        for p in range(0,5):
            aln.append(Sequence("Seq{}|blah".format(p), "MLAPLK"))
        aln = remove_taxa(bm[331], aln, basename)
        if len(aln) == 3:
            self.tests["AlnFiltSize"] = True
        if [x.label for x in aln] == ["Seq0|blah","Seq1|blah","Seq4|blah"]:
            self.tests["AlnFiltContent"] = True
    def run(self):
        self.remove_correct_taxa()
        
        print "Passed {} tests\n------------------".format(len([b for t,b in self.tests.iteritems() if b]))
        for t,v in self.tests.iteritems():
            res = "Fail"
            if v:
                res = "Pass"
            print "{}: {}".format(t,res)

def read_markers(f):
    markers = dict()
    lines = open(f,'r').readlines()[1:]
    for line in lines:
        spl = map(str.strip, line.split('\t'))
        if len(spl) < 2:
            continue
        if spl[0].startswith('#'):
            continue
        markers[spl[0]] = spl[1].split(';')
    return markers
def remove_taxa(spp, aln, basename):
    aln_filt = list(aln)
    keeping_track = list(spp)
    dump = list()
    for sp in spp:
        for seq in aln:
            if seq.label.split('|')[0] == sp:
                dump.append(seq.label)
                keeping_track.remove(sp)
                print "Removed target sequence {} from {}".format(seq.label, basename)
                break
    if len(keeping_track) != 0:
        print "Failed to find species ids in {}, {}".format(basename, keeping_track)
    for seq in dump:
        find = [aln_filt.index(x) for x in aln_filt if x.label == seq]
        assert len(find) == 1, "Duplication in badmarker file."
        aln_filt.pop(find[0])
    return aln_filt

helpmsg = "\nUSAGE: python remove_taxa_final_aln.py [bmfile] [aln_final_dir] [outdir]\n"

if len(sys.argv) < 4:
    if len(sys.argv) == 2:
        if sys.argv[1] == "test":
            Tests = Tests()
            Tests.run()
            sys.exit(0)
        elif sys.argv[1] in ["-h","--help"]:
            print helpmsg
            sys.exit(0)
        else:
            print "Unrecognized arugment: {}".format(sys.argv[1])
            sys.exit(1)
    else:
        print "Incorrect number of enough args... \n{}".format(helpmsg)
        sys.exit(1)

bad_markers = read_markers(sys.argv[1])
directory = os.path.abspath(sys.argv[2])
outdir = os.path.abspath(sys.argv[3])
lsdir = os.listdir(directory)

#pattern = re.compile("Roz_OGFLEX_([0-9]+).msa.trim")
pattern = re.compile("([0-9]+.[0-9]+).msa.trim")

if any([x not in [re.search(pattern, x).group(1) for x in [f for f in lsdir if f.endswith("msa.trim")]] for x in bad_markers.keys()]):
    print "Check badmarker file, a locus file was not found"
    sys.exit(1)

for fname in lsdir:
    if not fname.endswith(".msa.trim"):
        continue
    path = os.path.join(directory, fname)
    basename = os.path.split(path)[1]
    try:
        locus = re.match(pattern, basename).group(1)
        aln = readFasta(path, 'nucl', False)
        len_0 = len(aln)
    except:
        print "Skipping malformed file name, {}\n".format(basename)
        continue
    print "{}\n----------------------------".format(basename)
    if locus in bad_markers.keys():
        if bad_markers[locus][0] == "*":
            assert len(bad_markers[locus]) == 1, "If you want to delete the alignment, there must only be a single * in column"
            continue
        aln = remove_taxa(bad_markers[locus], aln, basename)
        if len(aln) != len_0-len(bad_markers[locus]):
            print "Failed to find one or more sequence ids, doing nothing with {}\n".format(basename)
            continue
    
    with open(os.path.join(outdir, "{}.filt".format(basename)), 'w') as f:
        for s in aln:
            if all([x == "-" for x in s.sequence]):
                print "Removed empty sequence, {}, from {}".format(s.label, basename)
                len_0 += 1
                continue
            else:
                f.write("{}\n".format(s.outFasta()))
        print "-*- Removed {} sequences from {} -*-\n".format(len_0-len(aln), basename)


