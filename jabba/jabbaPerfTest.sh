#!/bin/sh

# Usage:    sh jabbaPerfTest.sh {Experiment Number List} {Request Per Second List}
# Example : sh jabbaPerfTest.sh batch 5,10,15 100,200,300,350,400
# Example : sh jabbaPerfTest.sh single 1,3,6,9 100,200,300,350,400
# Example : sh jabbaPerfTest.sh batch 5,10,15 100,200,300,350,400,800 mixed

if [ -f jabbaPerfTest.pid ]; then
  echo "There is an instance of jabbaPerfTest is running, can't run two jabbaPerfTest instance at the same time"
  exit 1
fi
echo $$ > jabbaPerfTest.pid

user_str=""
batch_or_single=${1}
export batch_or_single
host=""

if [ "${batch_or_single}" == "single" ]; then
  test_file_prefix="jga512"
  log_type="tga512"
  mutual_exclusive=true
  output_file="single_list"
else
  test_file_prefix="jba512"
  log_type="tba512"
  mutual_exclusive=false
  output_file="batch_list"
fi

# By default, single assignment test mutual exclusion and batch assignment does
# not. but you can change it if you want to test otherwise.
# mutual_exclusive=false

# By default, we're testing server internal-jabba-perf-ilb-1595286552.us-west-2.elb.amazonaws.com.
# but you can change default host when need test other server.
# host=internal-jabba-perf-ilb-1595286552.us-west-2.elb.amazonaws.com

# read experiment numbers to mens
IFS=',' read -ra mens <<< "${2}"
# read throughput list to tpts
IFS=',' read -ra tpts <<< "${3}"
# Setting this flag as true we will delete every experiment we created for the
# test.  otherwise we will keep all files on batch_list_all that we can delete
# them all once.

# we support three modes: new, old, mixed 
mode="new"
if [ -n "${4}" ]; then
  mode=${4}
fi

housekeeping_need=true
if [ "${housekeeping_need}" == "false" ];
then
  rm -rf ${output_file}_all
fi

# Keep all
echo "Clean rurun file ${0}.rerun"
rm -rf ${0}.rerun
echo "Clean result file test_result"
rm -rf test_result

echo "Running throughput : " ${tpts[@]}
echo "Experiment numbers : " ${mens[@]}
mkdir -p logs

for throughput in ${tpts[@]}
do
  # Backup jmeter test file
  cp ${test_file_prefix}A.jmx .${test_file_prefix}A.bak
  cp ${test_file_prefix}C.jmx .${test_file_prefix}C.bak
  tpm=`expr ${throughput} \\* 60`
  tmp="${tpm}.0"
  # Default throughtput is 96000.0. We're setting throughtput here.
  # Given value is request per second, jmeter needs request per minute.
  sed -i -- "s/96000/${tpm}/g" ${test_file_prefix}A.jmx
  sed -i -- "s/96000/${tpm}/g" ${test_file_prefix}C.jmx
  if [ "${host}" != "" ]; then
    sed -i -- "s/internal-jabba-perf-ilb-1595286552.us-west-2.elb.amazonaws.com/${host}/g" ${test_file_prefix}A.jmx
    sed -i -- "s/internal-jabba-perf-ilb-1595286552.us-west-2.elb.amazonaws.com/${host}/g" ${test_file_prefix}C.jmx
  fi
  for exp_number in ${mens[@]}
  do
    echo batch_or_single=${1} >> ${0}.rerun
    echo export batch_or_single >> ${0}.rerun 
    echo runTest.sh ${exp_number} ${mutual_exclusive} ${mode} >> ${0}.rerun
    sh runTest.sh ${exp_number} ${mutual_exclusive} ${mode} 
    if [ $? -ne 0 ]; then
      echo "Error happened in runTest.sh, terminating tests and backup the result..."
      # No matter what we keep the result.
      mkdir ../../result
      mv test_result ../../result
      mv baklog* ../../result
      exit 1
    fi
    if [ "${housekeeping_need}" == "true" ];
    then
      sh deleteExperiments.sh ${output_file}
    else
      cat ${output_file} >> ${output_file}_all
    fi

    # Process the result.
    user_str=$(tr a-z A-Z <<< ${mode:0:1})${mode:1}
    user_str="${user_str} User"
    result=`sh extract_result.sh jmeter.log logs/${log_type}-${mode}.jtl`
    if [ "${mutual_exclusive}" == "true" ]; then
      with_str="With"
    else
      with_str="Without"
    fi
    me_str="(${with_str} Mutual Exclusive Throughput : ${throughput})"
    echo "${user_str}${me_str}: ${exp_number} Experiment" ${result} >> test_result
  done

  # restore jmeter files
  cp .${test_file_prefix}A.bak ${test_file_prefix}A.jmx
  cp .${test_file_prefix}C.bak ${test_file_prefix}C.jmx
  mkdir baklog-${batch_or_single}-${throughput}
  mv baklog/* baklog-${batch_or_single}-${throughput}
  #rename_files=`(cd baklog && ls)`
  #for file in ${files}
  #do
  #  mv baklog/${file} baklog/${batch_or_single}-${throughput}-${file}
  #done
done

# Move test result for artifactory
mkdir ../../result
mv test_result ../../result
mv baklog* ../../result

# remove pid file to prevent lock.
rm -rf jabbaPerfTest.pid
