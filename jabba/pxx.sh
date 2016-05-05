#!/bin/sh

xx=`expr 100 - ${1}`

N=$(wc -l < ${2})
cut -d, -f2 ${2} | sort -r -n | awk "NR >= $N*${xx}/100"'{print $1; exit}'
