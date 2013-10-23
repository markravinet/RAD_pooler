#!/bin/perl
# RAD_pooler_v0.1.pl - Mark Ravinet, University of Gothenburg, October 2013
use warnings;
use List::Util 'shuffle';
use Math::Random 'random_poisson';

# declare command line arguments

my $inputfilename = $ARGV[0];
my $outputfilename = $ARGV[1];
my $mean_expected_reads = $ARGV[2];

# This first section of code will read in the read count data and produce two arrays from
# the read count input

my (@files, @max_read_array); # declare column arrays

open( my $fh1, "<", $inputfilename ) || die "Can't open $inputfilename: $!";

while (<$fh1>) { # loop through the input
	chomp $_;
	# take each line, split by tab and assign to the variables
	my ($current_file, $current_total_read_count) = split ("\t", $_); 
	push (@files, $current_file);
	push (@max_read_array, $current_total_read_count);
}

close $fh1; # close filehandle

# This part of the program will loop through each of the files and extract the reads
# From each individual, it draws reads at random based on a poisson distribution of 
# the expected number of reads

my @output;

foreach(@files){
	my $max_reads = shift @max_read_array;
	my $extracted_reads = extract_multiple_reads($_, $max_reads, $mean_expected_reads);
	push (@output, $extracted_reads);

}

# for now - print the output to the screen 
open( my $fh2, ">", $outputfilename );
print {$fh2} "@output";
close $fh2;

exit;

################################################
# subroutines
################################################

sub poisson_shuffle {

	# subroutine to randomly generate indexes of reads to extract
	# based on a poisson distribution of contributions
	
	my($max_reads, $required_reads) = @_;
	my $poisson_reads = random_poisson(1, $required_reads);
	my @numbers = (shuffle(1..$max_reads))[1..$poisson_reads];
	
	return @numbers;
	
	}
	
sub read_line_index {
	# A subroutine to calculate the read line index for extraction
	my ($desired_read) = @_;
	my $start_line = ($desired_read * 4) - 3;
	my $end_line = 	$start_line + 4;
	
	return ($start_line, $end_line);
	}
	
sub read_extracter {
	# A subroutine to open the file and extract the given read
	my ($file, $desired_read) = @_;
	
	my @indexes = read_line_index($desired_read); # call read_line_index
	my $read; # declare read outside of loop

	
	open (my $fh, "<", $file) or die $!; # open the file
	
	
	until ( $indexes[0] == $indexes[1] ) {
		while (<$fh>) {
			
			if( $. == $indexes[0]){
			$read .= $_;
			$indexes[0] = $indexes[0]+1;
			last;

				}
			}
		}
  		close $fh;
  		# run descriptor writer to add ind name to fastq read header
 		my $new_read = descriptor_writer($file, $read);
   		return $new_read;
	#	return $read;  		
	}

sub descriptor_writer {
	# A subroutine to write a descriptor on the header line
	my ($ind, $read) = @_;
	
	$ind =~ s/.test.fq//g; # use regex to remove file suffix
	my @read = split("\n", $read); 
	$read[0] .= " ind=$ind"; # write individual name to header
	my $new_read = join("\n", @read); # rejoin the read
	return $new_read;
	}


sub extract_multiple_reads {
	# A subroutine to extract multiple reads from a file based on a poisson distribution
	my ($file, $max_reads, $expected_reads) = @_;
	
	# poisson_shuffle calculates number and indexes of reads to extract
	my @reads_to_extract = poisson_shuffle($max_reads, $expected_reads);
	my $extracted_reads;
	
	# foreach loop collects these reads using read_extracter
	foreach (@reads_to_extract) {
		$extracted_reads .= read_extracter($file, $_)."\n";
		}
	
	return $extracted_reads;
	}