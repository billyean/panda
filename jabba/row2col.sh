#!/bin/sh
#
# Convert test result file to one column of google doc can digest
#
# This script is based on the test result output format as follow: 
#########################################################################################################################################################################
# New User(Without Mutual Exclusive Throughput : 100): 5 Experiment Throughput : 100.3/s, Avg Time : 137, P50 : 136, P75 : 186, P90 : 243, P95 : 275, P99 : 351       #
# New User(Without Mutual Exclusive Throughput : 100): 10 Experiment Throughput : 100.3/s, Avg Time : 196, P50 : 138, P75 : 189, P90 : 242, P95 : 274, P99 : 350      #
# New User(Without Mutual Exclusive Throughput : 100): 15 Experiment Throughput : 100.3/s, Avg Time : 263, P50 : 141, P75 : 195, P90 : 251, P95 : 278, P99 : 350      #
# New User(Without Mutual Exclusive Throughput : 200): 5 Experiment Throughput : 200.3/s, Avg Time : 181, P50 : 143, P75 : 194, P90 : 250, P95 : 277, P99 : 349       #
# New User(Without Mutual Exclusive Throughput : 200): 10 Experiment Throughput : 200.2/s, Avg Time : 242, P50 : 146, P75 : 200, P90 : 252, P95 : 278, P99 : 349      #
# New User(Without Mutual Exclusive Throughput : 200): 15 Experiment Throughput : 200.0/s, Avg Time : 345, P50 : 148, P75 : 207, P90 : 262, P95 : 298, P99 : 379      #
# New User(Without Mutual Exclusive Throughput : 300): 5 Experiment Throughput : 300.1/s, Avg Time : 139, P50 : 147, P75 : 205, P90 : 261, P95 : 297, P99 : 379       #
# New User(Without Mutual Exclusive Throughput : 300): 10 Experiment Throughput : 298.7/s, Avg Time : 342, P50 : 149, P75 : 211, P90 : 272, P95 : 312, P99 : 398      #
# New User(Without Mutual Exclusive Throughput : 300): 15 Experiment Throughput : 300.3/s, Avg Time : 176, P50 : 151, P75 : 210, P90 : 271, P95 : 311, P99 : 398      #
# New User(Without Mutual Exclusive Throughput : 350): 5 Experiment Throughput : 347.8/s, Avg Time : 319, P50 : 153, P75 : 215, P90 : 278, P95 : 321, P99 : 425       #
# New User(Without Mutual Exclusive Throughput : 350): 10 Experiment Throughput : 346.9/s, Avg Time : 456, P50 : 155, P75 : 221, P90 : 292, P95 : 346, P99 : 506      #
# New User(Without Mutual Exclusive Throughput : 350): 15 Experiment Throughput : 349.2/s, Avg Time : 174, P50 : 156, P75 : 219, P90 : 291, P95 : 344, P99 : 505      #
# New User(Without Mutual Exclusive Throughput : 400): 5 Experiment Throughput : 395.9/s, Avg Time : 362, P50 : 158, P75 : 225, P90 : 301, P95 : 359, P99 : 520       #
# New User(Without Mutual Exclusive Throughput : 400): 10 Experiment Throughput : 381.5/s, Avg Time : 1119, P50 : 160, P75 : 231, P90 : 319, P95 : 410, P99 : 1140    #
# New User(Without Mutual Exclusive Throughput : 400): 15 Experiment Throughput : 395.4/s, Avg Time : 423, P50 : 162, P75 : 237, P90 : 334, P95 : 438, P99 : 1139     #
#########################################################################################################################################################################

prev_exp_no=0

while read line  
do  
  exp_no=`echo ${line} | cut -d' ' -f8`
  if [ ${exp_no} -lt ${prev_exp_no} ]; then
    echo
  fi
  echo
  # Get pos 12 rps and remove last 3 characters.
  rps=`echo ${line} | cut -d' ' -f12 | rev | cut  -c 4- | rev`
  avg=`echo ${line} | cut -d' ' -f16 | rev | cut  -c 2- | rev ` 
  p50=`echo ${line} | cut -d' ' -f19 | rev | cut  -c 2- | rev` 
  p75=`echo ${line} | cut -d' ' -f22 | rev | cut  -c 2- | rev` 
  p90=`echo ${line} | cut -d' ' -f25 | rev | cut  -c 2- | rev` 
  p95=`echo ${line} | cut -d' ' -f28 | rev | cut  -c 2- | rev` 
  p99=`echo ${line} | cut -d' ' -f31`
  echo ${rps}
  echo ${avg}
  echo ${p50}
  echo ${p75}
  echo ${p90}
  echo ${p95}
  echo ${p99}
  prev_exp_no=${exp_no}
done < ${1} 
