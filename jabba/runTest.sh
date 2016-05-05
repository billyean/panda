#!/bin/sh

# This test can be used to run as batch assignment or single assignment.
# Environment variable batch_or_single will decide what tests we will be doing.

# Check if server is healthy, otherwise terminate tests
ping_state=`curl -X GET http://internal-jabba-perf-ilb-1595286552.us-west-2.elb.amazonaws.com/api/v1/ping`
cassandra_state=`echo ${ping_state} | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["componentHealths"][0]["healthy"]'`
mysql_state=`echo ${ping_state} | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["componentHealths"][0]["healthy"]'`

if [ "${cassandra_state}" != "True" -o "${mysql_state}" != "True" ];
then
  echo "There are issues on server"
  exit 1
fi

# The number of experiments will be created
number_of_exp=${1}
# true or false
mutual_exclusive=${2}
# mode can be new, old or mixed.
mode=${3}

start_pos=12571
echo "batch_or_single = " ${batch_or_single}
if [ "${batch_or_single}" == "single" ]; then
  test_type="tsin"
  new_user_testfile="jga512A.jmx"
  mixed_user_testfile="jga512C.jmx"
  log_type="tga512"
  output_file="single_list"
else
  test_type="tbat"
  new_user_testfile="jba512A.jmx"
  mixed_user_testfile="jba512C.jmx"
  log_type="tba512"
  output_file="batch_list"
  # Only set same page when batch assignment test
  page_name="lt_page_${start_pos}"
fi
exp_name_prefix="${test_type}_phy"
application_name="${test_type}_loadtest"

if [ $# -eq 4 ]; then
  output_file=${4}
fi

echo "Application : ${application_name}; Experiment Prefix : ${exp_name_prefix}; Is mutual exclusive : ${mutual_exclusive}, Experiment Number: ${number_of_exp}; Page Prefix: ${page_name}"

# increment next_pos in early stage in case there is any issue
# when running.
next_pos=`expr ${start_pos} + ${number_of_exp}`
sh replace_pos.sh ${0} ${next_pos}

mkdir -p baklog/ logs/
# Format of log suffix example:
# 1. newuser-5-experiment-without-mutual-exclusive
# 2. mixeduser-15-experiment-with-mutual-exclusive
log_suffix="${number_of_exp}-experiment"
mutual_exclusive_str=""
if [ "${mutual_exclusive}" == "true"  ]; then
  mutual_exclusive_str="with-mutual-exclusive"
else
  mutual_exclusive_str="without-mutual-exclusive"
fi
log_suffix="${log_suffix}-${mutual_exclusive_str}"

if [ "${batch_or_single}" == "single" ]; then
  echo setup.sh -a ${application_name} -e ${exp_name_prefix} -m ${mutual_exclusive} -n ${number_of_exp} -o ${output_file} -s ${start_pos}
  sh setup.sh -a ${application_name} -e ${exp_name_prefix} -m ${mutual_exclusive} -n ${number_of_exp} -o ${output_file} -s ${start_pos}
  if [ $? -ne 0 ]; then
    echo "Error happened in setup.sh, terminating tests..."
    exit 1
  fi
  # Reason we store log file in log first because for old mode, we don't want to
  # save the new files.
  exp_label="${exp_name_prefix}_${start_pos}"
  case ${mode} in
    "new")
      echo java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${new_user_testfile} -Jappname=${application_name} -Jexperimentname=${exp_label} -l logs/${log_type}-new.jtl
      java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${new_user_testfile} -Jappname=${application_name} -Jexperimentname=${exp_label} -l logs/${log_type}-new.jtl > logs/${log_type}-new.log
      ;;
    "old")
      # For old mode, we run our tests twice, only collect second result.
      echo java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${new_user_testfile} -Jappname=${application_name} -Jexperimentname=${exp_label} -l logs/${log_type}-new.jtl
      java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${new_user_testfile} -Jappname=${application_name} -Jexperimentname=${exp_label} -l logs/${log_type}-new.jtl > logs/${log_type}-new.log
      echo java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${new_user_testfile} -Jappname=${application_name} -Jexperimentname=${exp_label} -l logs/${log_type}-old.jtl
      java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${new_user_testfile} -Jappname=${application_name} -Jexperimentname=${exp_label} -l logs/${log_type}-old.jtl > logs/${log_type}-old.log
      ;;
    "mixed")
      echo java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${mixed_user_testfile} -Jappname=${application_name} -Jexperimentname=${exp_label} -l logs/${log_type}-mixed.jtl
      java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${mixed_user_testfile} -Jappname=${application_name} -Jexperimentname=${exp_label} -l logs/${log_type}-mixed.jtl > logs/${log_type}-mixed.log
      ;;
  esac
else
  echo "setup.sh -a ${application_name} -e ${exp_name_prefix} -m ${mutual_exclusive} -n ${number_of_exp} -o ${output_file} -p ${page_name} -s ${start_pos}"
  sh setup.sh -a ${application_name} -e ${exp_name_prefix} -m ${mutual_exclusive} -n ${number_of_exp} -o ${output_file} -p ${page_name} -s ${start_pos}
  # Reason we store log file in log first because for old mode, we don't want to
  # save the new files.
  case ${mode} in
    "new")
      echo java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${new_user_testfile} -Jappname=${application_name} -Jpagename=${page_name} -l logs/${log_type}-new.jtl
      java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${new_user_testfile} -Jappname=${application_name} -Jpagename=${page_name} -l logs/${log_type}-new.jtl > logs/${log_type}-new.log
      ;;
    "old")
      # For old mode, we run our tests twice, only collect second result.
      echo java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${new_user_testfile} -Jappname=${application_name} -Jpagename=${page_name} -l logs/${log_type}-new.jtl
      java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${new_user_testfile} -Jappname=${application_name} -Jpagename=${page_name} -l logs/${log_type}-new.jtl > logs/${log_type}-new.log
      echo java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${new_user_testfile} -Jappname=${application_name} -Jpagename=${page_name} -l logs/${log_type}-old.jtl
      java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${new_user_testfile} -Jappname=${application_name} -Jpagename=${page_name} -l logs/${log_type}-old.jtl > logs/${log_type}-old.log
      ;;
    "mixed")
      echo java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${mixed_user_testfile} -Jappname=${application_name} -Jpagename=${page_name} -l logs/${log_type}-mixed.jtl
      java -Xms8192m -jar ~/apache-jmeter-2.12/bin/ApacheJMeter.jar -n -t ${mixed_user_testfile} -Jappname=${application_name} -Jpagename=${page_name} -l logs/${log_type}-mixed.jtl > logs/${log_type}-mixed.log
      ;;
  esac
fi

# Backup logs for further investigation.
cp logs/${log_type}-${mode}.jtl baklog/${log_type}-${log_suffix}.jtl
cp logs/${log_type}-${mode}.log baklog/${log_type}-${log_suffix}.log
cp jmeter.log  baklog/jmeter-${log_suffix}.log


error_no=`tail -1 baklog/jmeter-${log_suffix}.log  | awk '{print $20}'`
if [ ${error_no} -ne 0 ];
then
  echo "There are" ${error_no} "errors when run performance tests, please check the jtl file for the error type."
  #echo "There are" ${error_no} "errors when run performance tests, terminating tests now..."
  #exit 1
fi
