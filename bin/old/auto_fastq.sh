#!/bin/bash

CMDNAME=`basename $0`

while getopts i:o: OPT
do
  case $OPT in
    "i" ) FLG_A="TRUE" ; Iput_path="$OPTARG" ;;
    "o" ) FLG_B="TRUE" ; Output_path="$OPTARG" ;;
      * ) echo "Usage: $CMDNAME [-i VALUE] [-o VALUE] " 1>&2
          exit 1 ;;
  esac
done

mkdir -p $Output_path/
cd $Output_path/
mkdir -p temp/

find $Iput_path * | grep ^/.*.fastq.gz$ > temp/fatq1.dat
awk -v WD="$Iput_path" '{sub(WD, ""); print $0}' temp/fatq1.dat > temp/fatq2.dat
awk '{sub(".fastq.gz", ""); print $0}' temp/fatq2.dat > temp/fatq3.dat

# folderlist=$(<temp/fatq3.dat)
# for folder in $folderlist; do
# 	mkdir -p $Output_path$folder
# done

i=1
filelist=$(<temp/fatq1.dat)
for filepath in $filelist; do
	foldername=`cat temp/fatq3.dat | awk -v num="$i" 'NR==num'`
	echo "Proceeding file is " $foldername
	fastqc \
		--nogroup \
	    -t 4 \
	    $filepath \
	    -o $Output_path
	let i++
done

rm -rf temp/
echo "finish fastq-dump" | bash ~/Apps/notify-me.sh

exit 0
