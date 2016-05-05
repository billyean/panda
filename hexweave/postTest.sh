#!/bin/sh

test_type=$1
rm -rf ${test_type}/
mkdir -p ${test_type}/

java -Xms2048m -jar ~/apache-jmeter-2.13/bin/ApacheJMeter.jar -n -t create_${test_types}.jmx -Jtest_server=localhost -Jtest_server_port=8888 -Jworking_dir=/home/ec2-user -l ${test_type}.jtl > ${test_type}.log 


rm -rf ${test_type}_ids.json
touch ${test_type}_ids.json
files=`(cd ${test_type} && ls)`
for file in ${files}
do
  cat ${test_type}/${file} >> ${test_type}_ids.json
  echo >> ${test_type}_ids.json 
done
