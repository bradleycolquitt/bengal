#! /bin/bash

if [ $# -eq 0 ]; then
echo "Just install portion of kent doRepeatMaster.pl.\n
Installs \$db.fa.out, a RepeatMasked sequence into $db.rmsk and\n
creates bigBeds of repeat element classes"
echo "Usage: $0 db" ;
echo "";
echo "$db.fa.out is output file of RepeatMasker";
echo "";
exit 1;
fi

db=$1

hgLoadOut $db "$db".fa.out
hgLoadOut -verbose=2 -tabFile="$db".rmsk.tab -table=rmsk -nosplit "$db" "$db".fa.out 2> "$db".bad.records.txt

rm -fr classBed classBbi rmskClass
mkdir classBed classBbi rmskClass
sort -k12,12 "$db".rmsk.tab \
  | splitFileByColumn -ending=tab  -col=12 -tab stdin rmskClass
for T in SINE LINE LTR DNA Simple Low_complexity Satellite
do
    fileCount=`(ls rmskClass/"${T}"*.tab 2> /dev/null || true) | wc -l`
    if [ "$fileCount" -gt 0 ]; then
       echo "working: "`ls rmskClass/"${T}"*.tab | xargs echo`
       "$HOME"/kent/src/hg/utils/automation/rmskBed6+10.pl rmskClass/"${T}"*.tab \
        | sort -k1,1 -k2,2n > classBed/"$db".rmsk."${T}".bed
       bedToBigBed -tab -type=bed6+10 -as="$HOME"/kent/src/hg/lib/rmskBed6+10.as \
         classBed/"$db".rmsk."${T}".bed ../chrom.sizes \
           classBbi/"$db".rmsk."${T}".bb
    fi
done
fileCount=`(ls rmskClass/*RNA.tab 2> /dev/null || true) | wc -l`
if [ "$fileCount" -gt 0 ]; then
  echo "working: "`ls rmskClass/*RNA.tab | xargs echo`
  "$HOME"/kent/src/hg/utils/automation/rmskBed6+10.pl rmskClass/*RNA.tab \
     | sort -k1,1 -k2,2n > classBed/"$db".rmsk.RNA.bed
  bedToBigBed -tab -type=bed6+10 -as="$HOME"/kent/src/hg/lib/rmskBed6+10.as \
     classBed/"$db".rmsk.RNA.bed ../chrom.sizes \
        classBbi/"$db".rmsk.RNA.bb
fi
echo "working: "`ls rmskClass/*.tab | egrep -v "/SIN|/LIN|/LT|/DN|/Simple|/Low_complexity|/Satellit|RNA.tab" | xargs echo`
"$HOME"/kent/src/hg/utils/automation/rmskBed6+10.pl `ls rmskClass/*.tab | egrep -v "/SIN|/LIN|/LT|/DN|/Simple|/Low_complexity|/Satellit|RNA.tab"` \
        | sort -k1,1 -k2,2n > classBed/"$db".rmsk.Other.bed
bedToBigBed -tab -type=bed6+10 -as="$HOME"/kent/src/hg/lib/rmskBed6+10.as \
  classBed/"$db".rmsk.Other.bed ../chrom.sizes \
    classBbi/"$db".rmsk.Other.bb

export bbiCount=`for F in classBbi/*.bb; do bigBedInfo $F | grep itemCount; done | awk '{print $NF}' | sed -e 's/,//g' | ave stdin | grep total | awk '{print $2}' | sed -e 's/.000000//'`

export firstTabCount=`cat "$db".rmsk.tab | wc -l`
export splitTabCount=`cat rmskClass/*.tab | wc -l`

if [ "$firstTabCount" -ne $bbiCount ]; then
   echo "$db.rmsk.tab count: $firstTabCount, split class tab file count: $splitTabCount, bbi class item count:  $bbiCount"
   echo "ERROR: did not account for all items in rmsk class bbi construction" 1>&2
   exit 255
fi
wc -l classBed/*.bed > "$db".class.profile.txt
wc -l rmskClass/*.tab >> "$db".class.profile.txt
rm -fr rmskClass classBed "$db".rmsk.tab
