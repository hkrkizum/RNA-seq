#!/bin/bash
# mouse_annotation="/mnt/x/Bioinfomatics/Data/reference/Mouse/mouse_annotation.gtf"
mouse_annotation="/mnt/x/Bioinfomatics/Data/reference/Mouse_ref_genome_STAR/Mus_musculus.GRCm38.93.gtf"

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
cd $Output_path
mkdir -p temp/

find $Iput_path * | grep ^/.*.bam$ > temp/fatq1.dat
awk -v WD="$Iput_path" '{sub(WD, ""); print $0}' temp/fatq1.dat > temp/fatq2.dat
awk '{sub("Aligned.sortedByCoord.out.bam", ""); print $0}' temp/fatq2.dat > temp/fatq3.dat

i=1
filelist=$(<temp/fatq1.dat)
for filepath in $filelist; do
	foldername=`cat temp/fatq3.dat | awk -v num="$i" 'NR==num'`
	echo "output folder is " $foldername
	featureCounts \
  -T 8 \
  -t exon \
  -g gene_id \
  -a $mouse_annotation \
  -o ${foldername}_count.txt \
  $filepath
	let i++
done

exit 0
