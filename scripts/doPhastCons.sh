#! /bin/bash

maf=$1
IFS='-' read -a maf_array <<< "$maf"
target="${maf_array[0]}"
q="${maf_array[1]}"
query=${q%.*}
query=${query%.*}

tq="${target}-${query}"

if [ ! -d maf_split ]
then
    mkdir maf_split
    mafSplit -byTarget dummy.bed maf_split/ $maf
    # Background model from largest chromosome
    phyloFit -i MAF maf_split/000.maf

fi



if [ ! -d wig ]
then
    mkdir wig

    if [ ! -d mostCons ]
    then
	mkdir mostCons
    fi

    echo "Running phastCons..."
    for i in maf_split/*.maf 
    do 
	x=`basename $i .maf`
	phastCons --target-coverage 0.25 --expected-length 12 \
	--rho 0.4 --msa-format MAF $i phyloFit.mod \
	--seqname `cat $i | head -n 3  | tail -n 1 | tr -s ' ' | cut -f 2 -d ' ' | cut -d. -f2` \
	--most-conserved mostCons/$x.bed > wig/$x.wig
    done
fi

echo "Loading into browser..."
cat wig/*.wig > ${tq}.pp
wigEncode ${tq}.pp ${tq}.wig ${tq}.wib

if [ ! -d /gbdb/${target}/wib ]
then 
    sudo mkdir /gbdb/${target}/wib/
fi

echo "Wig..."
sudo cp ${tq}.wib /gbdb/${target}/wib/
hgLoadWiggle  -pathPrefix=/gbdb/${target}/wib ${target} phastCons${query} ${tq}.wig

echo "Most Conversed bed..."
cat mostCons/*.bed > mostCons.bed
hgLoadBed ${target} mostConserved${query} mostCons.bed
