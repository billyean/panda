#!/bin/sh

# Usage sh perfTest.sh [test type]
# test type can be orgs, employees, emails, address or edges_between_orgs_customers

test_type=$1
API_SERVER_IP=10.97.17.20
API_SERVER_PORT=8888

JMETER_HOME=${PWD}/apache-jmeter-2.13
JMETER_TEST_DIR=${PWD}/test
WORKING_DIR=${PWD}/data
RESULT_DIR=${PWD}/result
LOG_DIR=${PWD}/logs

rm -rf ${RESULT_DIR}/${test_type}/
mkdir -p ${RESULT_DIR}/${test_type}/
mkdir -p ${LOG_DIR}

data_size=`cat ${WORKING_DIR}/${test_type}.csv|wc -l`
number_of_threads=20
loop_counter=`expr ${data_size} / ${number_of_threads}`

echo "java -Xms2048m -jar ${JMETER_HOME}/bin/ApacheJMeter.jar -n -t ${JMETER_TEST_DIR}/create_${test_type}.jmx -Jtest_server=${API_SERVER_IP} -Jtest_server_port=${API_SERVER_PORT} -Jresult_dir=${RESULT_DIR} -Jworking_dir=${WORKING_DIR} -Jnumber_of_threads=${number_of_threads} -Jloop_counter=${loop_counter} -l ${LOG_DIR}/${test_type}.jtl > ${LOG_DIR}/${test_type}.log"
java -Xms2048m -jar ${JMETER_HOME}/bin/ApacheJMeter.jar -n -t ${JMETER_TEST_DIR}/create_${test_type}.jmx -Jtest_server=${API_SERVER_IP} -Jtest_server_port=${API_SERVER_PORT} -Jresult_dir=${RESULT_DIR} -Jworking_dir=${WORKING_DIR} -Jnumber_of_threads=${number_of_threads} -Jloop_counter=${loop_counter} -l ${LOG_DIR}/${test_type}.jtl > ${LOG_DIR}/${test_type}.log

CURRENT_TIME=`date '+%y%m%d%H%M%S'`
mv jmeter.log ${LOG_DIR}/jmeter-${test_type}.log.${CURRENT_TIME}

rm -rf ${test_type}_ids.json
touch ${test_type}_ids.json
files=`(cd ${RESULT_DIR}/${test_type} && ls)`
for file in ${files}
do
  cat ${RESULT_DIR}/${test_type}/${file} >> ${test_type}_ids.json
  echo >> ${test_type}_ids.json
done

echo "Test done, please check all generated ids on file ${test_type}_ids.json"
