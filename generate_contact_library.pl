use strict;
use warnings;

# File paths
my $sam_file1 = "sra_1_chrX.sam";
my $sam_file2 = "sra_2_chrX.sam";
my $output_file = "contact_library.txt";

# Hash to store read IDs and their mapping coordinates
my %reads1;
my %reads2;

# Process the first SAM file
open(my $fh1, '<', $sam_file1) or die "Cannot open $sam_file1: $!";

while (my $line = <$fh1>) {
	# Skip header lines that start with @
	next if $line =~ /^@/;  
	# Parse the SAM file line
	my @fields = split(/\t/, $line);
                         
	# Extract the read ID and mapping coordinate
	# The read ID is in field 0, the coordinate is in field 3
	my $read_id = $fields[0];
	my $coordinate = $fields[3];
                                            
	# Store in hash, but only if valid mapping (not 0)
	if ($coordinate != 0) {
		# Remove the .1 suffix to match with the second file's .2 suffix
		$read_id =~ s/\.1$//;
		$reads1{$read_id} = $coordinate;
	}
}

close$fh1;

# Process the second SAM file
open(my $fh2, '<', $sam_file2) or die "Cannot open $sam_file2: $!";

while (my $line = <$fh2>) {
	# Skip header lines
	next if $line =~ /^@/;
             
	# Parse the SAM file line
	my @fields = split(/\t/, $line);
                         
	# Extract the read ID and mapping coordinate
	my $read_id = $fields[0];
	my $coordinate = $fields[3];
                                         
	# Store in hash, but only if valid mapping (not 0)
	if ($coordinate != 0) {
		# Remove the .2 suffix to match with the first file's .1 suffix
		$read_id =~ s/\.2$//;
		$reads2{$read_id} = $coordinate;
	}	
}
close $fh2;

# Open output file
open(my $out_fh, '>', $output_file) or die "Cannot open $output_file for writing: $!";
# Compare the two hashes and find matching pairs
foreach my $id (keys %reads1) {
	# Check if the ID exists in both hashes (paired read)
	if (exists $reads2{$id}) {
	# Write the coordinates to the output file
		print $out_fh "$reads1{$id} $reads2{$id}\n";
	}	
}

close $out_fh;

print "Contact library has been generated in $output_file\n";
