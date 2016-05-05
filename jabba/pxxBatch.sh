#!/bin/sh

# pxx.sh is really slow operation, we could have more efficient way to calculate
# multiple pxx at the same time.
# Be cautious, we only support Pxx and Pxxx here, don't pass any value greater
# than 1000.

function cal_pxx() {
  pxx_str=""
  file=${1}
  shift
  for xx in ${@}
  do
    if [ ${xx} -gt 100 ]; then
      yy=`expr 1000 - ${xx}`
      base=1000
    else
      yy=`expr 1000 - ${xx}`
      base=100
    fi
    N=$(wc -l < ${file})
    pxx=`cut -d, -f2 ${file} | sort -r -n | awk "NR >= $N*${yy}/${base}"'{print $1; exit}'`
    if [ -z ${pxx_str} ]; then
      pxx_str="P${xx} : ${pxx}"
    else
      pxx_str="${pxx_str}, P${xx} : ${pxx}"
    fi
  done
}
