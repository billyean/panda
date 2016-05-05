#!/bin/sh

function incre_start() {
  num_line=`grep -r '"numRows":' $1`
  numRows=`echo ${num_line} | awk -F"[: ,]" '{print $5}'`

  is_line=`grep -r '"incrementStart":' $1`
  incrementStart=`echo ${is_line} | awk -F"[: ,]" '{print $5}'`

  new_incrementStart=`expr ${incrementStart} + ${numRows}`

  old_is_str="\"incrementStart\": ${incrementStart}"
  new_is_str="\"incrementStart\": ${new_incrementStart}"

  sed -i -- "s/${old_is_str}/${new_is_str}/g" $1
}


file=$1
file_prefix=`echo ${file} | cut -d'.' -f1`
num_line=`grep -r '"numRows":' ${file}`
numRows=`echo ${num_line} | awk -F"[: ,]" '{print $5}'`
total=`expr ${2} / ${numRows}`

rm -rf ${file_prefix}/
mkdir -p ${file_prefix}/

index=1
while [ ${index} -le ${total} ];
do
  generated_file="${file_prefix}_${index}.csv" 
  curl -H'Content-Type: application/json' -X POST -d @${1} http://localhost:8888/api/v1/data > ${file_prefix}/${generated_file}
  incre_start ${file}
  index=`expr ${index} + 1`
  tr '\r' '\n' < ${file_prefix}/${generated_file} > ${file_prefix}/${generated_file}.tmp
  sed 1d ${file_prefix}/${generated_file}.tmp > ${file_prefix}/${generated_file}
  rm ${file_prefix}/${generated_file}.tmp
done

cat ${file_prefix}/${file_prefix}_*.csv > ${file_prefix}/${file_prefix}.csv
