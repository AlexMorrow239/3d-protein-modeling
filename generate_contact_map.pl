use strict;
use warnings;
use POSIX;

# Constants for chromosome X
my $CHR_X_LENGTH = 154913754;
my $RESOLUTION = 1000000;
my $NUM_BINS = ceil($CHR_X_LENGTH / $RESOLUTION);

# Check if input file is provided
my $input_file = $ARGV[0] || "contact_library.txt";
my $output_file = "chrX_1Mb_contact_map.txt";

print "Processing $input_file to create $output_file\n";
print "Chromosome X length: $CHR_X_LENGTH\n";
print "Resolution: $RESOLUTION\n";
print "Number of bins: $NUM_BINS\n";

# Open input file
open(my $in, "<", $input_file) or die "Cannot open $input_file: $!";

# Process file and build contact map
my %contacts;  # Hash to store contacts
my $line_count = 0;

while (my $line = <$in>) {
    $line_count++;
    chomp($line);
    
    # Skip empty lines
    next if $line =~ /^\s*$/;
    
    # Parse the line - expecting two numbers separated by space
    my ($pos1, $pos2) = split(/\s+/, $line);
    
    # Skip if either position is not a number or exceeds chromosome length
    unless (defined $pos1 && defined $pos2 && 
            $pos1 =~ /^\d+$/ && $pos2 =~ /^\d+$/ &&
            $pos1 <= $CHR_X_LENGTH && $pos2 <= $CHR_X_LENGTH) {
        print "Warning: Line $line_count has invalid format or position exceeds chromosome length: $line\n" if $line_count <= 5;
        next;
    }
    
    # Calculate bin indices using ceil(position/1000000)-1 as recommended
    my $bin1 = ceil($pos1/$RESOLUTION) - 1;
    my $bin2 = ceil($pos2/$RESOLUTION) - 1;
    
    # Skip invalid bin indices (negative or beyond number of bins)
    next if $bin1 < 0 || $bin2 < 0 || $bin1 >= $NUM_BINS || $bin2 >= $NUM_BINS;
    
    # Add contact to map (symmetric)
    my $key = "$bin1,$bin2";
    $contacts{$key}++;
    
    # Also update symmetric entry if different bins
    if ($bin1 != $bin2) {
        my $rev_key = "$bin2,$bin1";
        $contacts{$rev_key}++;
    }
}

close($in);

print "\nProcessed $line_count contact pairs.\n";

# Write contact map to output file
open(my $out, ">", $output_file) or die "Cannot open $output_file: $!";

# Write the contact map in the exact format needed
for my $i (0..$NUM_BINS-1) {
    for my $j (0..$NUM_BINS-1) {
        my $key = "$i,$j";
        my $value = exists $contacts{$key} ? $contacts{$key} : 0;
        print $out $value;
        print $out "\t" if $j < $NUM_BINS-1;
    }
    print $out "\n";
}

close($out);

print "Output file created: $output_file\n";
print "Contact map created with $NUM_BINS x $NUM_BINS dimensions.\n";
