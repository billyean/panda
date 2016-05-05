#!/bin/sh

# Usage:    sh batchLoop.sh {single or batch} {Experiment Number List} {Request Per Second List}
# Example : sh batchLoop.sh batch 5,10,15 100,200,300,350,400
# Example : sh batchLoop.sh single 1,3,6,9 100,200,300,350,400
user_str=""

batch_or_single=${1}
export batch_or_single

if [ "${batch_or_single}" == "single" ]; then
  test_file_prefix="jga512"
  mutual_exclusive=true
  output_file="single_list"
else
  test_file_prefix="jba512"
  mutual_exclusive=false
  output_file="batch_list"
fi

# By default, single assignment test mutual exclusion and batch assignment does
# not. but you can change it if you want to test otherwise.
# mutual_exclusive=false

# By default, we're testing server internal-jabba-perf-ilb-1595286552.us-west-2.elb.amazonaws.com.
# but you can change default host when need test other server.
# mutual_exclusive=false



# read experiment numbers to mens
IFS=',' read -ra mens <<< "${2}"
# read throughput list to tpts
IFS=',' read -ra tpts <<< "${3}"
# Setting this flag as true we will delete every experiment we created for the
# test.  otherwise we will keep all files on batch_list_all that we can delete
# them all once.
housekeeping_need=true
if [ "${housekeeping_need}" == "false" ];
then
  rm -rf ${output_file}_all
fi

echo "Clean result file"
rm -rf test_result

echo ${tpts[@]}
echo ${mens[@]}

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
  if [ -n ${host} ]; then
    sed -i -- "s/internal-jabba-perf-ilb-1595286552.us-west-2.elb.amazonaws.com/${host}/g" ${test_file_prefix}A.jmx
    sed -i -- "s/internal-jabba-perf-ilb-1595286552.us-west-2.elb.amazonaws.com/${host}/g" ${test_file_prefix}C.jmx
  fi
  for exp_number in ${mens[@]}
  do
    echo sh runTest.sh ${exp_number} ${mutual_exclusive} new >> ${0}.rerun
    sh runTest.sh ${exp_number} ${mutual_exclusive} new
    if [ "${housekeeping_need}" == "true" ];
    then
      sh deleteExperiments.sh ${output_file}
    else
      cat ${output_file} >> ${output_file}_all
    fi
    # Process the result.
    user_str="New User"
    result=`sh extract_result.sh jmeter.log logs/tba512-new.jtl`
    if [ "${mutual_exclusive}" == "true" ]; then
      with_str="With"
    else
      with_str="Without"
    fi
    me_str="(${with_str} Mutual Exclusive Throughput : ${throughput})"
    echo "${user_str}${me_str} : ${exp_number} Experiment " ${result} >> test_result
  done
  # restore jmeter files
  cp .${test_file_prefix}A.bak ${test_file_prefix}A.jmx
  cp .${test_file_prefix}C.bak ${test_file_prefix}C.jmx
  mkdir baklog-${batch_or_single}-${throughput}
  mv baklog/* baklog-${batch_or_single}-${throughput}
done
