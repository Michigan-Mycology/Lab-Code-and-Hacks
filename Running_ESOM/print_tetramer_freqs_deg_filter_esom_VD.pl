#!/usr/bin/perl
# Anders Andersson 2007
# Modified by Itai Sharon, Nov/2010
use strict;

my $prog 		= $ARGV[0];
my $seqfile 		= undef;	#fasta file, may include X:s and N:s
my $annotationfile 	= undef;	#full contig name in left, annotation in right, column. headers (whatever) on first line 
my $min_length 		= 3000;		#minimal length (in nt) of input contig to be included in output
my $kmer_size 		= 2;
my $window_size 	= 3000; 	# split sequence after each window_size nt, join last part, if shorter than window_size, with second-last part (a sequence of 
					# 14 kb will be split into a 5 kb and a 9 kb fragment if window_size = 5 kb)

(($#ARGV >= 1) && ($#ARGV%2 == 1)) or usage("Incorrect number of parameters");

for(my $i=0; $i<$#ARGV; $i+=2) {
	my $flag = $ARGV[$i];	
	my $param = $ARGV[$i+1];
	if(($flag eq '-s') || ($flag eq '-seqfile')) {
		$seqfile = $param;
	}
	elsif(($flag eq '-a') || ($flag eq '-annotation_file')) {
		$annotationfile = $param;
	}
	elsif(($flag eq '-m') || ($flag eq '-min_length')) {
		$min_length = $param;
	}
	elsif(($flag eq '-w') || ($flag eq '-window_size')) {
		$window_size = $param;
	}
	elsif(($flag eq '-k') || ($flag eq '-kmer_size')) {
		$kmer_size = $param;
	}
	else {
		usage("unknown parameter $flag");
	}
}

defined($seqfile) or die "Input sequence file (-s) not specified\n\n";
(-e $seqfile) or die "\nCould not find $seqfile\n\n";

#!!! Program will automatically create outfiles called (whatever) infile.lrn and infile.names (and overwrite existing) !!!

my $lrnfile =	$seqfile."\.lrn";
my $namesfile = $seqfile."\.names";
my $classfile = $seqfile."\.cls";


my %allowed = ();	# Allowed k-mers
my @mers = ();		# Allowed k-mers in a vector organization (do we really need that and not keys %allowed?)
my @names = ();
my @tetras = ();

################################################################################################################

prepare_annotation_file();
make_list_of_possible_tetramers('', $kmer_size);
calc_tetra_freqs();
make_lrn_file();
make_names_file();
make_class_file();

################################################################################################################
# This will create the list of all possible k-mers, for any reasonable k-mer size.
sub make_list_of_possible_tetramers {
	my ($mer, $k) = @_;

	if($k == 0) {
		my $rc_mer = make_revcomp($mer);
		if (!defined $allowed{$rc_mer}) {
			push (@mers, $mer);
			$allowed{$mer}++;
		}
		return;
	}

	my @bases = ("A", "T", "C", "G");
	foreach my $na (@bases) {
		make_list_of_possible_tetramers("$mer$na", $k-1);
	}
}

################################################################################################################
sub calc_tetra_freqs {
	print STDERR "calculating tetranucleotide frequencies ";
    	my $total_index = 0;
    	my ($id, $seq) = (undef, "");

	open (INFILE, $seqfile) || die "can't open $seqfile!";
	my $counter = 0;
    	while (<INFILE>) {
        	chomp;
        	if ($_ =~ />(\S+)/) {
			print STDERR '.' if($counter++%500 == 0);
			my $next_id = $1;
			get_tetra_freqs($id, $seq) if (length($seq) >= $min_length);
			($id, $seq) = ($next_id, '');
			
        	} else {
            		$seq .= $_;
        	}
    	}

	# Last sequence
    	if (length($seq) >= $min_length) {
        	get_tetra_freqs($id, $seq);
    	}
    	close (INFILE);
	print STDERR "ok, $counter data points\n";
}

################################################################################################################
my $total_index = 0;
sub get_tetra_freqs {
	my ($id, $seq) = @_;

    	# filter out short sequences between N's and X's 
    	# as well as between these and beginning and end of sequence
    	my @lowqual = ();
    	push(@lowqual, 0); #to get start position
    	foreach my $i (0 ..  (length($seq) - $kmer_size - 1)) {
        	my $base = substr($seq, $i, 1);
        	if ($base eq "N" || $base eq "X") {
            		push(@lowqual, $i);
        	}
    	}
    	push(@lowqual, length($seq)); #to get end position
    	my $filtered_seq = $seq;
    	foreach my $i (1 .. $#lowqual) {
        	my $length = $lowqual[$i] - $lowqual[$i - 1] - 1;		# Why -1? it should be +1
        	if ($length < 50) {
        	    	for (my $j = $lowqual[$i - 1]; $j < $lowqual[$i]; $j++) {
        	        	substr($filtered_seq, $j, 1) = "Z";
        	    	}
        	}
    	}
    	$seq = $filtered_seq;
    	$seq = uc($seq);		# This should be done earlier otherwise you may miss n's or x's
    
    	#split sequence into subsequences
    	my @sub_seq = ();
    	if (length($seq) < 2*$window_size) {
        	@sub_seq = ($seq);
    	} else {
        	for(my $i=0; $i<length($seq); $i = $i + $window_size) {
            		my $subseq = substr($seq, $i, $window_size);
            		push(@sub_seq, $subseq);
        	}
        	if (length($sub_seq[-1]) < $window_size) {
            		$sub_seq[-2] = $sub_seq[-2].$sub_seq[-1];
            		pop (@sub_seq);
        	}
    	}
    
    	#calculate and print freqs for each subsequence
    	my $sub_index = 0;
	    my $last = 0;
		my $first = 0;
    	foreach $seq (@sub_seq) {
	        $first = $last + 1;
	        $last = $first + length($seq) - 1;
        	$sub_index++;
        	my %this_mers = ();
        	my $sum = 0;
        	foreach my $i (0 .. (length($seq)-1)) {
            		my $mer = substr($seq, $i, $kmer_size);
            		if (defined $allowed{$mer}) {
                		$this_mers{ $mer }++;
                		$sum++;
            		} else {
                		my $rc_mer = &make_revcomp($mer);
                		if (defined $allowed{$rc_mer}) {
                    			$this_mers{ $rc_mer }++;
                    			$sum++;
                		}
            		}
        	}
		my $tetra = "";
            	$total_index++;
            	my $name = "$total_index\t$id".":"."$first-$last\t$id";
            	push(@names, $name);
            
            	foreach my $mer (@mers) {
                	if (defined $this_mers{$mer}) {
                    		my $counts = $this_mers{$mer}/$sum;
	                    	$tetra = $tetra."\t".$counts;
                	} else {
                    		$tetra = $tetra."\t0";
                	}
            	}            
            	push(@tetras, $tetra);
	}
}

################################################################################################################
sub make_revcomp {
	my $rc = $_[0];
	$rc =~ tr/ACGT/TGCA/;
	return reverse($rc);
}

################################################################################################################
sub make_lrn_file {
	print STDERR "printing lrn file $lrnfile ... ";
	open (OUT, ">$lrnfile") || "can't create outfile $lrnfile";
	my $number_rows = @names;
    	my $number_cols = @mers + 1;
    	print OUT "% $number_rows\n";
    	print OUT "% $number_cols\n";
    	print OUT "% 9";
    	foreach my $mer (@mers) {
        	print OUT "\t1";
    	}
    	print OUT "\n";
    	print OUT "% Key";
    	foreach my $mer (@mers) {
        	print OUT "\t$mer";
    	}
    	print OUT "\n";
    	my $key = 0;
    	foreach my $tetra (@tetras) {
        	$key++;
        	print OUT "$key$tetra\n";
    	}
    	close (OUT);
	print STDERR "ok\n";
}

################################################################################################################
sub make_names_file {
 	print STDERR "printing names file $namesfile ... ";
	my $number_rows = @names;
	open (OUT, ">$namesfile");
	print OUT "% $number_rows\n";
	foreach my $name (@names) {
		print OUT "$name\n";
    	}
    	close (OUT);
	print STDERR "ok\n";
}

################################################################################################################
sub make_class_file {
    	print STDERR "printing class file $classfile ... ";
	my %class = ();
	my $line = 0;

    	open (INFILE, $annotationfile) || die "can't open $annotationfile";
#	$_ = <INFILE>;	# Read header line
    	while (<INFILE>) {
        	$line++;
		chomp;
		# contig	annotation
		my @fields = split(/\t/, $_);
		$fields[0] =~ s/\s+$//;
		$class{$fields[0]} = $fields[1];	# This used to be ... = $fields[2]; but this must be wrong since there are only $fields[0] and $fields[1]...
    	}
    	close (INFILE);

	open (OUT, ">$classfile");
   	my $number_rows = @names;
    	print OUT "% $number_rows\n";
    	foreach my $item (@names) {
        	#print "$item\n";
        	my @fields = split(/\t/, $item);
        	print OUT "$fields[0]\t$class{$fields[2]}\n";
#        	die "$fields[0]\t$class{$fields[2]}\t:\t$fields[2]\n";
    	}
    	close (OUT);
	print STDERR "ok\n";
}

################################################################################################################
sub usage() {		
	print STDERR $_[0], "\n" if($#_ != -1);

	print STDERR "\nUsage: $0 -s <seqfile> [-a <annotation file>] [-m <minimum length>] [-w <window size>] [-k <kmer size>]\n\n";
	print STDERR "  -s,-seq_file: input fasta file (mandatory)\n";
	print STDERR "  -a,-annotation_file: annotation file in the format of <sequence>\t<annotation>. File may be complete or partial. \n";
	print STDERR "           The program will complete the missing entries with annotation \"0\". path would be <seqfile>.annotation\n";
	print STDERR "  -m,-min_length: minimum length of sequences that will be considered (default: 5,000bp)\n";
	print STDERR "  -w,-window_size: window size (default: 5,000)\n";
	print STDERR "  -k,-kmer_size: k-mer size (default: 4)\n\n";
	die;
}

################################################################################################################
sub prepare_annotation_file {
	print STDERR "Preparing annotation file ... ";
	my %sequences = ();
	# First, read supplied annotations (if any)
	if(defined($annotationfile)) {
		open(IN, $annotationfile) or die "\nCannot read $annotationfile\n\n";
		while(<IN>) {
			chomp;
			my ($seq, $annot) = split(/\t/);
			$sequences{$seq} = $annot;
		}
		close(IN);
	}

	# Next, read $seqfile and add 0 annotations to all sequences without annotations
	my $write_out = 0;
	open(IN, $seqfile) or die "\nCannot read $seqfile\n\n";
	while(<IN>) {
		if(($_ =~ />(\S+)/) && !exists($sequences{$1})) {
			$sequences{$1} = 0;
			$write_out = 1;
		}
	}
	close(IN);

	if(!$write_out) {
		print STDERR "ok, all data points were labeled, did not have to write a new annotation file\n";
		return;
	}

	my $new_annot_file = "$seqfile.annotation";

	if(-e $new_annot_file) {
		my $answer = "";
		while($answer !~ /^yes|no$/) {
			print STDERR "\n$new_annot_file already exists; overwrite? (yes/no): ";
			$answer = <STDIN>;
		}
		($answer eq "yes\n") or die "Cannot overwrite $new_annot_file, leaving\n";
	}
	open(OUT, ">$new_annot_file") or die "\nCannot open $new_annot_file for writing\n\n";
	print OUT "contig	annotation\n";
	while (my ($s, $a) = each %sequences) {
		print OUT "$s\t$a\n";
	}
	close(OUT);
	$annotationfile = $new_annot_file;
	print STDERR "ok, labeled unlabeled data points with 0, new annotation file is $annotationfile\n";
}
