use strict;
use warnings;
use POSIX;

# Input and output files
my $input_file = "chrX_1Mb_contact_map.txt";
my $output_file = "chrX_1Mb_distance_map.txt";

print "Converting $input_file to distance map $output_file\n";

# Open input file
open(my $in, "<", $input_file) or die "Cannot open input file $input_file: $!";

# Read contact map
my @contact_map;
my $row_idx = 0;
my $num_cols = 0;

while (my $line = <$in>) {
    chomp($line);
    my @row = split(/\t/, $line);
    $contact_map[$row_idx] = [@row];
    $num_cols = scalar(@row) if $row_idx == 0;
    $row_idx++;
}

close($in);

my $num_bins = $row_idx;
print "Read contact map with dimensions: $num_bins x $num_cols\n";

if ($num_bins == 0 || $num_cols == 0) {
    die "Error: Empty or invalid contact map file.\n";
}

# Check if dimensions match
if ($num_bins != $num_cols) {
    die "Error: Contact map must be square.\n";
}

# Find rows with all zeros
my @non_zero_rows;
for my $i (0..$num_bins-1) {
    my $has_non_zero = 0;
    for my $j (0..$num_bins-1) {
        if ($contact_map[$i][$j] > 0) {
            $has_non_zero = 1;
            last;
        }
    }
    push @non_zero_rows, $i if $has_non_zero;
}

my $new_size = scalar(@non_zero_rows);
print "Found $new_size non-zero rows/columns (original size: $num_bins)\n";

if ($new_size != 153) {
    print "Warning: Expected 153 non-zero rows/columns, but found $new_size\n";
}

# Create new contact matrix with only non-zero rows/columns
my @filtered_contact_map;
for my $i (0..$new_size-1) {
    for my $j (0..$new_size-1) {
        $filtered_contact_map[$i][$j] = $contact_map[$non_zero_rows[$i]][$non_zero_rows[$j]];
    }
}

# Calculate the baseline distance value for x=1 as per requirements
my $baseline_distance = 1 / (1 ** (1/3));  # This equals 1, but explicitly showing the formula

# Convert contact frequencies to distances
my @distance_map;
my $non_zero_contacts = 0;
my $zero_contacts = 0;

for my $i (0..$new_size-1) {
    for my $j (0..$new_size-1) {
        my $contact = $filtered_contact_map[$i][$j];
        my $distance;
        
        if ($contact > 0) {
            # Convert contact to distance using correct formula y = (1/x)^(1/3)
            $distance = 1 / ($contact ** (1/3));
            $non_zero_contacts++;
        } else {
            # If no contact, use the baseline distance (value from x=1) as specified
            $distance = $baseline_distance;
            $zero_contacts++;
        }
        
        $distance_map[$i][$j] = $distance;
    }
}

print "Non-zero contacts: $non_zero_contacts\n";
print "Zero contacts replaced with baseline distance: $zero_contacts\n";

# Write distance map to output file
open(my $out, ">", $output_file) or die "Cannot open output file $output_file: $!";

for my $i (0..$new_size-1) {
    for my $j (0..$new_size-1) {
        printf $out "%.6f", $distance_map[$i][$j];
        print $out "\t" if $j < $new_size-1;
    }
    print $out "\n";
}

close($out);

my $output_size = -s $output_file;
print "Distance map created: $output_file (size: $output_size bytes)\n";