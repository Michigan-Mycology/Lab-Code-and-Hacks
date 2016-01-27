#!/bin/perl

# Qiime needs fasta names that are prefixed with the group origin, while mothur uses sequence names, but then associates them with a group file.
# This script takes a mothur group file and then converts that into a hash that gives for each sequence name, the corresponding group
# Then it parses through a fasta file and an OTU file and for each sequence, it replaces it with an appropriate name, where the sequence name is prepended 
# with a group name

# An improvement would be to make this so that it can also make the other transition from qiime to mothur

# Expect the file to be run as perl convert_mothur_to_qiime.pl groupfile otufile fastafile
#---------------------------------------------------------------------------
#  Open files
#---------------------------------------------------------------------------
open (GROUPFILE, "$ARGV[0]"); # Opens the group file
open (OTUFILE, "$ARGV[1]"); # Opens the OTU file
open (FASTAFILE, "$ARGV[2]"); # Opens the fasta file
open (NEWOTUFILE, "> $ARGV[1]_new"); # Creates a new OTU file
open (NEWFASTAFILE, "> $ARGV[2]_new"); # Creates a new fasta file

#---------------------------------------------------------------------------
#  Main
#---------------------------------------------------------------------------
my %group_hash; 
read_group_file(); # key: seqid, value:group
foreach my $name (keys %group_hash) {print "$name = $group_hash{$name}\n";}
parsethroughfasta();
parsethroughOTUs();

#---------------------------------------------------------------------------
# Read in group file and make a hash
#---------------------------------------------------------------------------
sub read_group_file {
   	my %groups; 
   	my $index;
   	
  	while (<GROUPFILE>) 
  	{
  		@index = split(/\t/, $_); # Divide the line on the basis of tabs
        $index[1] =~ s/\s+$//; # remove trailing whitespace
        print "index[0]=$index[0] index[1]=$index[1]\n";
        $group_hash{$index[0]} = $index[1];
 	}
}

#---------------------------------------------------------------------------
# Takes fasta input and group files and writes out a new fasta file
#---------------------------------------------------------------------------
sub parsethroughfasta {
   	my $header;
   	my $groupname;
   	my $newname;
   	
  	while (<FASTAFILE>) 
  	{
    	if (/>/) 
    	{
    		$header = $_;
    		$header =~ s/^>//; # remove ">" 
    		print "header = $header";
    		$header =~ s/\s+$//; # remove trailing whitespace
    		$groupname = $group_hash{$header};
    		print "groupname = $groupname\n";
    		$newname = ">"."$groupname"."_"."$header"."\n";
    		print NEWFASTAFILE "$newname";
    	}         
    	else
    	{    
    		print NEWFASTAFILE "$_";
    	}         
   	}    
}

#---------------------------------------------------------------------------
# Takes mothur format OTUs and adds group names to make it qiime compatible
#---------------------------------------------------------------------------
sub parsethroughOTUs {
   	my $size;
   	my $groupname;
   	my $newname;
   	my @list;
   	
   	@list = ();
  	while (<OTUFILE>) 
  	{
  		my @list = split(/\t/, $_); # Divide the line on the basis of tabs 
  		print NEWOTUFILE "$list[0]";
  		print "$list[0]";
  		my $i = 1;
  		while ($list[$i])
  		{
  			$groupname = $group_hash{$list[$i]};
 			$newname = "$groupname"."_"."$list[$i]";
  			print "\n$list[0] groupname = $groupname newname = $newname $i";
 		  	print NEWOTUFILE "\t$newname";
 		  	$i++;
  		}
  		print "exited";
  		print NEWOTUFILE "\n";
  		@list = ();
   	}    
   	close(NEWOTUFILE);
}
