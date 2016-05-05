#!/bin/sh

# Usage:  sh regen_result.sh [test set] [folder kept jmeter log files and jtl files]
# Example:sh regen_result.sh tba512 baklog-batch-100 baklog-batch-200 baklog-batch-300 baklog-batch-350 baklog-batch-400

test_set=$1
shift

for folder in $@
do
  # Assume folder format is baklog-[batch|signgle]-xxx, xxx is target throughput.
  target_throughput=`echo ${folder} | cut -d"-" -f3`
  # jmeter file format is jmeter-newuser-xx-experiment-[without|with]-mutual-exclusive.log
  # sort the file name with xx.
  jmeter_files=`(cd ${folder} && ls jmeter* | sort -t '-' -n -k3)`
  for jmeter_file in ${jmeter_files}
  do
    prefix=`echo ${jmeter_file} |cut -d'.' -f1`
    last_line=`tail -n 1 ${folder}/${jmeter_file}`
    throughput=`echo ${last_line} | cut -d " " -f12`
    avg_time=`echo ${last_line} | cut -d " " -f14`
    jtl_file=`echo ${folder}/${prefix} | sed -e 's/jmeter/tba512/g'`
    mode=`echo ${prefix} | cut -d'-' -f2`
    exp_no=`echo ${prefix} | cut -d'-' -f3`
    with_or_without=`echo ${prefix} | cut -d'-' -f5`
    with_or_without="$(tr '[:lower:]' '[:upper:]' <<< ${with_or_without:0:1})${with_or_without:1}"
    case ${mode} in
      "newuser")
        line="New User"
        ;;
      "olduser")
        line="Old User"
        ;;
      "mixeduser")
        line="Mixed User"
        ;;
    esac
    p50=`sh pxx.sh 50 ${jtl_file}.jtl`
    p75=`sh pxx.sh 75 ${jtl_file}.jtl`
    p90=`sh pxx.sh 90 ${jtl_file}.jtl`
    p95=`sh pxx.sh 95 ${jtl_file}.jtl`
    p99=`sh pxx.sh 99 ${jtl_file}.jtl`

    line="${line}(${with_or_without} Mutual Exclusive Throughput : ${target_throughput}): ${exp_no} Experiment Throughput : ${throughput}, Avg Time : ${avg_time}, P50 : ${p50}, P75 : ${p75}, P90 : ${p90}, P95 : ${p95}, P99 : ${p99}"
    echo ${line}
  done
done
