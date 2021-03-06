#! /bin/bash

if [ $# -eq 0 ]; then
echo "Installs simpleRepeat.bed into specified database."
echo "Usage: $0 db" ;
echo "";
exit 1;
fi

db=$1

hgLoadBed $db simpleRepeat simpleRepeat.bed \
        -sqlTable="$HOME"/kent/src/hg/lib/simpleRepeat.sql
featureBits $db simpleRepeat >& fb.simpleRepeat
