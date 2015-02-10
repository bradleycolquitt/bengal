# From kent doRepeatMasker.pl

# * step: install [dbHost, maybe fileServer]
sub doInstall {
  my $runDir = "$buildDir";
  &HgAutomate::checkExistsUnlessDebug('cat', 'install', "$buildDir/$db.sorted.fa.out");

  my $split = "";
  $split = " (split)" if ($opt_splitTables);
  my $whatItDoes =
"It loads $db.sorted.fa.out into the$split rmsk$updateTable table and $db.nestedRepeats.bed\n" .
"into the nestedRepeats table.  It also installs the masked 2bit.";
  my $bossScript = newBash HgRemoteScript("$runDir/doLoad.bash", $dbHost,
				      $runDir, $whatItDoes);

  $split = "-nosplit";
  $split = "-split" if ($opt_splitTables);
  my $installDir = "$HgAutomate::clusterData/$db";
  $bossScript->add(<<_EOF_
export db=$db

hgLoadOut -table=rmsk$updateTable $split \$db \$db.sorted.fa.out
hgLoadOut -verbose=2 -tabFile=\$db.rmsk$updateTable.tab -table=rmsk$updateTable -nosplit \$db \$db.sorted.fa.out 2> \$db.bad.records.txt
# construct bbi files for assembly hub
rm -fr classBed classBbi rmskClass
mkdir classBed classBbi rmskClass
sort -k12,12 \$db.rmsk$updateTable.tab \\
  | splitFileByColumn -ending=tab  -col=12 -tab stdin rmskClass
for T in SINE LINE LTR DNA Simple Low_complexity Satellite
do
    fileCount=`(ls rmskClass/\${T}*.tab 2> /dev/null || true) | wc -l`
    if [ "\$fileCount" -gt 0 ]; then
       echo "working: "`ls rmskClass/\${T}*.tab | xargs echo`
       \$HOME/kent/src/hg/utils/automation/rmskBed6+10.pl rmskClass/\${T}*.tab \\
        | sort -k1,1 -k2,2n > classBed/\$db.rmsk.\${T}.bed
       bedToBigBed -tab -type=bed6+10 -as=\$HOME/kent/src/hg/lib/rmskBed6+10.as \\
         classBed/\$db.rmsk.\${T}.bed ../../chrom.sizes \\
           classBbi/\$db.rmsk.\${T}.bb
    fi
done
fileCount=`(ls rmskClass/*RNA.tab 2> /dev/null || true) | wc -l`
if [ "\$fileCount" -gt 0 ]; then
  echo "working: "`ls rmskClass/*RNA.tab | xargs echo`
  \$HOME/kent/src/hg/utils/automation/rmskBed6+10.pl rmskClass/*RNA.tab \\
     | sort -k1,1 -k2,2n > classBed/\$db.rmsk.RNA.bed
  bedToBigBed -tab -type=bed6+10 -as=\$HOME/kent/src/hg/lib/rmskBed6+10.as \\
     classBed/\$db.rmsk.RNA.bed ../../chrom.sizes \\
        classBbi/\$db.rmsk.RNA.bb
fi
echo "working: "`ls rmskClass/*.tab | egrep -v "/SIN|/LIN|/LT|/DN|/Simple|/Low_complexity|/Satellit|RNA.tab" | xargs echo`
\$HOME/kent/src/hg/utils/automation/rmskBed6+10.pl `ls rmskClass/*.tab | egrep -v "/SIN|/LIN|/LT|/DN|/Simple|/Low_complexity|/Satellit|RNA.tab"` \\
        | sort -k1,1 -k2,2n > classBed/\$db.rmsk.Other.bed
bedToBigBed -tab -type=bed6+10 -as=\$HOME/kent/src/hg/lib/rmskBed6+10.as \\
  classBed/\$db.rmsk.Other.bed ../../chrom.sizes \\
    classBbi/\$db.rmsk.Other.bb

export bbiCount=`for F in classBbi/*.bb; do bigBedInfo \$F | grep itemCount; done | awk '{print \$NF}' | sed -e 's/,//g' | ave stdin | grep total | awk '{print \$2}' | sed -e 's/.000000//'`

export firstTabCount=`cat \$db.rmsk$updateTable.tab | wc -l`
export splitTabCount=`cat rmskClass/*.tab | wc -l`

if [ "\$firstTabCount" -ne \$bbiCount ]; then
   echo "\$db.rmsk$updateTable.tab count: \$firstTabCount, split class tab file count: \$splitTabCount, bbi class item count:  \$bbiCount"
   echo "ERROR: did not account for all items in rmsk class bbi construction" 1>&2
   exit 255
fi
wc -l classBed/*.bed > \$db.class.profile.txt
wc -l rmskClass/*.tab >> \$db.class.profile.txt
rm -fr rmskClass classBed \$db.rmsk$updateTable.tab
_EOF_
  );

  if ($opt_updateTable) {
  $bossScript->add(<<_EOF_
sed -e 's/nestedRepeats/nestedRepeatsUpdate/g' \$HOME/kent/src/hg/lib/nestedRepeats.sql > nestedRepeatsUpdate.sql
hgLoadBed \$db nestedRepeats$updateTable \$db.nestedRepeats.bed \\
  -sqlTable=nestedRepeatsUpdate.sql
_EOF_
  );
  } else {
  $bossScript->add(<<_EOF_
hgLoadBed \$db nestedRepeats \$db.nestedRepeats.bed \\
  -sqlTable=\$HOME/kent/src/hg/lib/nestedRepeats.sql
_EOF_
  );
  }

  $bossScript->add(<<_EOF_
rm -f $installDir/\$db.rmsk$updateTable.2bit
ln -s $buildDir/\$db.rmsk$updateTable.2bit $installDir/\$db.rmsk$updateTable.2bit
_EOF_
  );
  $bossScript->execute();

  # Make a new script for the fileServer if chrom-based:
  if ($chromBased) {
    my $fileServer = &HgAutomate::chooseFileServer($runDir);
    $whatItDoes =
"It splits $db.sorted.fa.out into per-chromosome files in chromosome directories\n" .
"where makeDownload.pl will expect to find them.\n";
    my $bossScript = new HgRemoteScript("$runDir/doSplit.csh", $fileServer,
					$runDir, $whatItDoes);
    $bossScript->add(<<_EOF_
head -3 $db.sorted.fa.out > /tmp/rmskHead.txt
tail -n +4 $db.sorted.fa.out \\
| splitFileByColumn -col=5 stdin /cluster/data/$db -chromDirs \\
    -ending=.fa.out -head=/tmp/rmskHead.txt
_EOF_
    );
    $bossScript->execute();
  }
} # doInstall

