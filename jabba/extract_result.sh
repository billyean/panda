#!/bin/sh

# Extract test result.
# Usage  : sh extract_result.sh {jmeter_file} {jtl_file}
# Example: sh extract_result.sh jmeter.log logs/jga512A.jtl

line=`tail -n 1 ${1}`
throughput=`echo $line | cut -d " " -f12`
avg_time=`echo $line | cut -d " " -f14`
p50=`sh pxx.sh 50 ${2}`
p75=`sh pxx.sh 75 ${2}`
p90=`sh pxx.sh 90 ${2}`
p95=`sh pxx.sh 95 ${2}`
p99=`sh pxx.sh 99 ${2}`

echo "Throughput : ${throughput}, Avg Time : ${avg_time}, P50 : ${p50}, P75 : ${p75}, P90 : ${p90}, P95 : ${p95}, P99 : ${p99}"
