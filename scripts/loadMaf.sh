#! /bin/bash

target=$1
query=$2
modifiers=$3
maf=$4

echo $query

shortmaf=maf${query}
fullmaf=maf${query}${modifiers}

hgLoadMafSummary $target ${fullmaf}Summary $maf

if [ ! -d /gbdb/${target}/${shortmaf} ]
then
    mkdir /gbdb/${target}/${shortmaf}
fi

cp $maf /gbdb/${target}/${shortmaf}/${fullmaf}.maf
hgLoadMaf -loadFile=/gbdb/${target}/${shortmaf}/${fullmaf}.maf ${target} ${shortmaf}
