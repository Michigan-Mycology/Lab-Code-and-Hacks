#HOW TO RUN: perl ClusterRemover.pl endfile.end fasta.fa
use Data::Dumper;
#reads in the Table
open(TABLE, $ARGV[0])||die "No Table\n";
while($line = <TABLE>){
	
	chomp $line;
	($file_name, $rest) = split ":", $line, 2;
#	print "$rest\n";
	@array = split " ", $rest;
	foreach $i (0..$#array){
		$HASH{$file_name}[$i] = $array[$i];
	}

}
#print Dumper(\%HASH);
$count = 0;
open(FASTA, $ARGV[1])||die "No Fasta\n";
while ($line = <FASTA>){

	chomp $line;
	if ($line =~ /^>/){

		if ($count != 0){
	
			$seq_hash{$gi} = $seq;
		}
		#print "$line\n";
		$gi = ($line =~ m/gi\|(.*?)\|.*/)[0];
		#print "$gi\n";
		$seq = "";
	}else{

		$seq .= $line;
	}

	$count++;
}
$seq_hash{$gi} = $seq;
foreach $key (keys %HASH){

	open(out, ">>$key\_file\.to_remove");
	#print "$HASH{$key}[1]\n";
	foreach $i (0..$#{$HASH{$key}}){

		$gi = ($HASH{$key}[$i] =~ m/gi\|(.*?)\|.*/)[0];
		if (exists $seq_hash{$gi}){

			print out ">$HASH{$key}[$i]\n$seq_hash{$gi}\n";

		}
	}	

	
}


Kindly written by Joe Walker (contributed here by Jill Myers)
