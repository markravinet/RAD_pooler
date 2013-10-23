RAD_pooler
==========
# Mark Ravinet, University of Gothenburg, October 2013

Perl and bash scripts to sample reads from a set of fastq files

RAD_pooler is a simple set of perl and bash scripts which will allow the user to draw a random subset of short DNA
sequence reads from a group of individual fastq files and to create a larger fastq file, containing all artificially
'pooled' reads.

RAD_pooler takes three arguments (supplied to the perl script via the bash wrapper script). These are:
1) the input filename
2) the output filename
3) the expected number of reads

The most important part of using the program is calculating the expected number of reads. Reads from each individual will
be drawn from a poisson distribution based on this number - thus the number of reads individuals contribute will vary.

At present, RAD_pooler will also add an identifier to the fastq header line for each read. This is taken from the
name for the individual read files and allows the user to track which reads belong to which individual.

