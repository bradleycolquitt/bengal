#! /bin/bash

cd /gbdb/lonStrDom1
gfServer start -stepSize=5 bengal 17779 lonStrDom1.2bit &

cd /gbdb/taeGut2
gfServer start -stepSize=5 bengal 17849 taeGut2.2bit &
