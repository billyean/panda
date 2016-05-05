#!/bin/sh

map_file1=$1
map_file2=$2
result_file=$3

number_of_file1=`cat ${map_file1} | wc -l`
number_of_file2=`cat ${map_file2} | wc -l`

quotient=`expr ${number_of_file2} / ${number_of_file1}`
reminder=`expr ${number_of_file2} % ${number_of_file1}`

rm ${result_file}
rm -f ${map_file1}.tmp
touch ${map_file1}.tmp

counter=0

while [ ${counter} -lt ${quotient} ]
do
  cat ${map_file1} >> ${map_file1}.tmp
  counter=`expr ${counter} + 1`
done

if [ ${reminder} -gt 0 ]; then
  head -${reminder} ${map_file1} >> ${map_file1}.tmp
fi
paste -d ',' ${map_file1}.tmp ${map_file2} >> ${result_file}
rm -f ${map_file1}.tmp
