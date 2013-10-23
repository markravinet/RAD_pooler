#!/bash

# Simple bash to provide filename and read count

if [ -f readcount.txt ]
then
    	\rm readcount.txt
fi

touch readcount.txt

for f in ./*.fq; do

c=$(wc -l $f | awk '{ print $1/4}')
echo -e "${f#./}\t$c" >> readcount.txt

done

# produces an output with file name and total number of reads from fastq files
