def pickle_loader (pklFile):
    try:
        while True:
            yield pickle.load(pklFile)
    except EOFError:
            pass
#%%
def pkl_fasta_in_out (org_fname, seq_type = "nucl", contig_info = True):
    pkl_fname = org_fname.split("/")[-1]+'.pkl'
    if os.path.isfile(os.getcwd()+"/"+pkl_fname):
        objlist = []
        with open(pkl_fname,'r') as input:
            for seq in pickle_loader(input):
                objlist.append(seq)
    else:
        objlist = readFasta(org_fname, seq_type, contig_info)
        with open(pkl_fname,'w') as output:
            for seq in objlist:
                pickle.dump(seq, output, pickle.HIGHEST_PROTOCOL)
    return objlist

#%%
class bcolors:
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

#%%
class color_changing_formatter(logging.Formatter):
    def __init__(self, fmt="%(levelno)s: %(msg)s",datefmt="%Y-%m-%d @ %H:%M:%S"):
        logging.Formatter.__init__(self, fmt, datefmt)

    def format(self, record):
        orig_format = self._fmt
        if record.levelno == 20:
            self._fmt = bcolors.MAGENTA+'[%(asctime)s]'+bcolors.ENDC+'[%(name)s] %(message)s'
        elif record.levelno == 30:
            self._fmt = bcolors.WARNING+'[%(asctime)s]'+bcolors.ENDC+'[%(name)s] %(message)s'
        elif record.levelno ==50:
            self._fmt = bcolors.FAIL+'[%(asctime)s]'+bcolors.ENDC+'[%(name)s] %(message)s'
        result = logging.Formatter.format(self, record)
        self._fmt = orig_format
        return result

def logger1(name):
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    ch = logging.StreamHandler()
    ch.setLevel(logging.INFO)
    fh = logging.FileHandler(name+'_logfile')
    fh.setLevel(logging.INFO)
    ch_formatter = color_changing_formatter()
    tolog_formatter = logging.Formatter('[%(asctime)s] - [%(name)s] - %(message)s','%y-%m-%d @ %H:%M:%S')
    ch.setFormatter(ch_formatter)
    fh.setFormatter(tolog_formatter)
    logger.addHandler(ch)
    logger.addHandler(fh)

    return logger
def transcribe(nucl_seq):
    transcript = ""
    trans = {
            'A':'U',
            'T':'A',
            'G':'C',
            'C':'G',
            'N':'N'
            }
    for letter in nucl_seq:
        transcript+=trans[letter]
    return transcript
#%%
def complement(string):
    out = ""
    comp = {
            'A':'U',
            'U':'A',
            'G':'C',
            'C':'G',
            'N':'N'
            }
    for letter in string:
        out+=comp[letter]
    return out

#%%
def translate_dna_to_protein (string):
    dna_to_aa = {'ATA':'I', 'ATC':'I', 'ATT':'I', 'ATG':'M',
    'ACA':'T', 'ACC':'T', 'ACG':'T', 'ACT':'T',
    'AAC':'N', 'AAT':'N', 'AAA':'K', 'AAG':'K',
    'AGC':'S', 'AGT':'S', 'AGA':'R', 'AGG':'R',
    'CTA':'L', 'CTC':'L', 'CTG':'L', 'CTT':'L',
    'CCA':'P', 'CCC':'P', 'CCG':'P', 'CCT':'P',
    'CAC':'H', 'CAT':'H', 'CAA':'Q', 'CAG':'Q',
    'CGA':'R', 'CGC':'R', 'CGG':'R', 'CGT':'R',
    'GTA':'V', 'GTC':'V', 'GTG':'V', 'GTT':'V',
    'GCA':'A', 'GCC':'A', 'GCG':'A', 'GCT':'A',
    'GAC':'D', 'GAT':'D', 'GAA':'E', 'GAG':'E',
    'GGA':'G', 'GGC':'G', 'GGG':'G', 'GGT':'G',
    'TCA':'S', 'TCC':'S', 'TCG':'S', 'TCT':'S',
    'TTC':'F', 'TTT':'F', 'TTA':'L', 'TTG':'L',
    'TAC':'Y', 'TAT':'Y', 'TAA':'_', 'TAG':'_',
    'TGC':'C', 'TGT':'C', 'TGA':'_', 'TGG':'W',
    }
    out = ""
    for pos in range(0,len(string),3):
        out+= dna_to_aa[string[pos:pos+3]]
    return out

#%%
def best_blast_hit (tabular):
    best = {}
    for line in open(tabular).readlines():
        spl = line.split("\t")
        spl = map(str.strip,spl)
        label = spl[0]
        bit = float(spl[7])
        if label in best.keys():
            if best[label][7] > bit:
                best[label] = spl
        else:
            best[label] = spl

    return best
#%%
def extract_cds_gff3 (gff3, nucl):
    nucl_dict = {}
    for obj in nucl:
        node = obj.label.split('_')[0:2]
        node = '_'.join(node)
        node = node.replace("NODE_","N")
        nucl_dict[node] = obj.sequence
    cds_only = {}
    for line in open(gff3).readlines():
        if line[0] == "#":
            continue
        if line.split('\t')[2] == "CDS":
            spl = line.split("\t")
            node = spl[0].split('_')[0:2]
            node = '_'.join(node)
            node = node.replace("NODE_","N")
            #print node
            #node = "_".join(node.split('_')[0:2])
            s = re.search("[.](g[0-9]+)[.]",spl[8])
            pid = s.group(1)
            if node in cds_only.keys():
                if pid in cds_only[node].keys():
                    cds_only[node][pid].append(spl[1:len(spl)-1])
                else:
                    cds_only[node][pid] = [spl[1:len(spl)-1]]
            else:
                cds_only[node] = {
                        pid: [spl[1:len(spl)-1]]
                        }
    cds_cat = []
    for node,pids in cds_only.iteritems():
        node_cds_cat = ""
        #print node
        for prot,cds_chunks in pids.iteritems():
            gene_cds = ""
            for cds in cds_chunks:
                start = cds[2]
                stop = cds[3]
                gene_cds += nucl_dict[node][int(start)-1:int(stop)]
            if len(gene_cds) % 3 == 0:
                node_cds_cat += gene_cds
        cds_cat.append(sequence(node, node_cds_cat, seq_type='nucl', contig_info=False))
    return cds_cat
#%%
def remove_small_sequences (list_of_sequence_objects, min_len):
    list_to_output = []
    for sequence_object in list_of_sequence_objects:
        if len(sequence_object.sequence) >= int(min_len):
            list_to_output.append(sequence_object)
    return list_to_output
#%%
def file_grep (pattern, file, mode='first'):
    if mode not in ['first','multiple']:
        raise NameError("Invalid option, "+mode)
    result_list = []
    with open(file,'r') as f:
        for line in f.readlines():
            if re.search(pattern,line) is not None:
                if mode is 'first':
                    return line.strip()
                elif mode is 'multiple':
                    result_list.append(line.strip())
    return result_list

#%%
def replace_line(file, old, new):
    head = ""
    tail = ""
    line_start = 0
    line_end = 0
    with open(file,'r') as f:
        pos = 0
        trunc_point = 0
        present = False
        for line in f.readlines():
            if line.strip() == old:
                line_start = pos
                line_end = pos + len(line)
                present = True
                break
            pos += len(line)
        if present is False:
            raise ValueError("The line you want to replace is not present in the file.")
        f.seek(0)
        head = f.read(line_start)
        f.seek(line_end)
        tail = f.read()
    with open(file, 'w') as f:
        f.write(head)
        f.write(new+'\n')
        f.write(tail)

#%%
def get_line(file, to_get):
    with open(file,'r') as f:
        for line in f.readlines():
            if line.strip() == to_get:
                return to_get
#%%
def log_command_line_errors (err, name):
    if err != '':
        err = err.split('\n')
        for i in err:
            if len(i) > 0:
                logger.critical('['+name+' error] '+i)
