#!/bin/bash
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
cd $Output_path
mkdir -p temp/

# Get file list
find $Iput_path * | grep ^/.*.bam$ > temp/fatq1.dat
awk -v WD="$Iput_path" '{sub(WD, ""); print $0}' temp/fatq1.dat > temp/fatq2.dat
awk '{sub(".bam", ""); print $0}' temp/fatq2.dat > temp/fatq3.dat

i=1
filelist=$(<temp/fatq1.dat)
for filepath in $filelist; do
	# リストのファイル名をループ回数に応じて取得、変数へ格納
	foldername=`cat temp/fatq3.dat | awk -v num="$i" 'NR==num'`
	echo "Proceeding file is " $foldername

	java -jar /home/hikaru/Apps/picard/build/libs/picard.jar AddOrReplaceReadGroups \
 	I=$filepath \
 	O=${foldername}_RG.bam \
 	SO=coordinate \
 	RGID=Test RGLB=TruSeq_RNA_stranded RGPL=illumina RGPU=HiSeq2000 RGSM=Test

	echo "Complete" $foldername

	let i++
done
rm -rf temp/

echo "Complete QC" | bash ~/Apps/notify-me.sh
exit 0