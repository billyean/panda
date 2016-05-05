#!/bin/sh

# Usage: sh loopRun.sh {Max_Experiment_Number} {Thread_Per_Test}

count=1
user_str=""
# Setting this flag as true we will delete every experiment we created for the test.
# otherwise we will keep all files on batch_list_all that we can delete them all once.
housekeeping_need=true
if [ "${housekeeping_need}" == "false" ];
then
  rm -rf batch_list_all
fi

rm -rf test_result
cp jba512A.jmx .jba512A.bak
cp jba512C.jmx .jba512C.bak

tpm=`expr ${2} \\* 60`
tmp="${tpm}.0"
sed -i -- "s/96000/${tpm}/g" jba512A.jmx
sed -i -- "s/96000/${tpm}/g" jba512C.jmx

while [ ${count} -le ${1} ];
do
  for mode in "new" "old" "mixed"
  do
    for mutual_exclusive in "true" "false"
    do
      sh runBatch.sh ${count} ${mutual_exclusive} ${mode}
      if [ "${housekeeping_need}" == "true" ]; then
        sh deleteExperiments.sh
      else
        cat batch_list >> batch_list_all
      fi
      # Process the result.
      case ${mode} in
        "new")
          user_str="New User"
          jtl_file="tba512-new"
          ;;
        "old")
          user_str="Old User"
          jtl_file="tba512-old"
          ;;
        "mixed")
          user_str="Mixed User"
          jtl_file="tba512-mixed"
          ;;
      esac
      result=`sh extract_result.sh jmeter.log logs/${jtl_file}.jtl`
      if [ ${mutual_exclusive} == "true" ];
      then
        me_str="(With Mutual Exclusive)"
      else
        me_str="(Without Mutual Exclusive)"
      fi
      echo "${user_str}${me_str}: ${count} experiment " ${result} >> test_result
    done
  done
  count=`expr ${count} + 1`
done

# restore jmeter files
cp .jba512A.bak jba512A.jmx
cp .jba512C.bak jba512C.jmx
