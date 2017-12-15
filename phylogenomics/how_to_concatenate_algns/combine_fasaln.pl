#!/usr/bin/perl -w
use strict;
use Bio::AlignIO;
use Bio::SimpleAlign;
use Bio::LocatableSeq;
use Getopt::Long;
my $iformat = 'fasta';
my $oformat = 'nexus';
my $outfile = 'allseq.nex';
my $ext = '';
my $dir;
my @expected;
my $expected_file;
my $debug ;
my $include;
GetOptions('d|dir:s'   => \$dir,
'ext:s'     => \$ext,
'if:s'       => \$iformat,
'of:s'       => \$oformat,
'expected:s' => \$expected_file,
'o|out:s'   => \$outfile,
'v|debug!' => \$debug,
'include:s' => \$include,
);

die("need a dir") unless $dir && -d $dir;

opendir(DIR, $dir) || die"$dir: $!";

if( $expected_file && open(my $fh => $expected_file) ) {
while(<$fh>) {
chomp;
s/^>//;
push @expected, $_;
}
}
my %allowed;
if( $include ) {
open(my $fhi => $include) || die $!;
while(<$fhi>) {
my ($g) = split;
$allowed{$g}++;
}
}
my (%matrix);
my @part;
my $last = 1;
for my $file (sort readdir(DIR) ) {
next if $file eq $outfile;
warn("file is $file\n");
next unless ($file =~ /(\S+)\.\Q$ext\E$/);
my $stem = $1;
if( $include ) {	
#warn "checking if $stem is in the allowed set\n";
# skip if we aren't in the allowed list (when this is specified)
next unless $allowed{$stem};
warn("$stem is allowed inclusion\n") if $debug;
}
my $in = Bio::AlignIO->new(-format => $iformat, -alphabet => 'protein',
-file   => "$dir/$file");
my ($fbase) = split(/\./,$file);
warn($file,"\n") if $debug;
if( my $aln = $in->next_aln ) {
my $now = $last + $aln->length - 1;
push @part, "$fbase = $last-$now;";
$last = $now + 1;
my %seen;
for my $seq ( $aln->each_seq ) {
my $id = $seq->id;
if( $seq->length == 0 ) {
warn("no length for seq ", $id,"\n");
}
warn("id is $id\n") if $debug;
if( $id =~ /([^\|]+)\|/) { 
$id = $1;
}
my $s = $seq->seq;
$s =~ s/\./-/g;
$s = uc $s;
$matrix{$id} .= $s;
$seen{$id}++;
}
for my $exp ( @expected ) {
if( ! $seen{$exp} ) {
$matrix{$exp} .= '-' x $aln->length;
}
}
}
}

my $bigaln = Bio::SimpleAlign->new;
while( my ($id,$seq) = each %matrix ) {
    
    warn("seq $id length is ",length($seq),"\n");
    $bigaln->add_seq(Bio::LocatableSeq->new(-id  => $id,
    					    -seq => $seq));
    					    }
    					    $bigaln->set_displayname_flat(1);

    					    my $out = Bio::AlignIO->new(-format => $oformat,
    					    			    -file   => ">$outfile");
    					    			    $out->write_aln($bigaln);

 print join("\n",@part),"\n";
