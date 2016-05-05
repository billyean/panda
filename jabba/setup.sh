#!/bin/sh

# This is a script for setting up experiments generally.
# -a [App Name]
# -e [Experiment Name Prefix]
# -h [Host Server]
# -m [Mutual Exclusive]
# -n [Experiment Numbers]
# -o [File Name for storing experiments]
# -p [Page Name Prefix]
# -s [Experiment Start Value]
# Example: sh setup.sh -a Idea_Perf -e Exp_Idea -n 2 -o batch_exp_list -s 10001

# Default configuration
# No page name if not given.
page_name=""
if [ -z ${host} ]; then
  host=internal-jabba-perf-ilb-1595286552.us-west-2.elb.amazonaws.com
fi
mutual_exclusive="false"
output_file="batch_list"

while getopts a:e:h:m:n:o:p:s: opt
do
  case "${opt}" in
    a)
      app_name="${OPTARG}"
      echo "app_name = " ${OPTARG}
      ;;
    e)
      exp_name_prefix="${OPTARG}"
      echo "exp_name_prefix = " ${OPTARG}
      ;;
    h)
      host="${OPTARG}"
      echo "host = " ${OPTARG}
      ;;
    m)
      mutual_exclusive="${OPTARG}"
      echo "mutual_exclusive = " ${OPTARG}
      ;;
    n)
      number_of_experiment="${OPTARG}"
      echo "number_of_experiment = " ${OPTARG}
      ;;
    o)
      output_file="${OPTARG}"
      echo "output_file = " ${OPTARG}
      ;;
    p)
      page_name="${OPTARG}"
      echo "page_name = " ${OPTARG}
      ;;
    s)
      echo "start_value = " ${OPTARG}
      start_value=${OPTARG}
      ;;
    ?)
      echo "Usage: $0 -a [App Name] -e [Experiment Name Prefix] -h [Host Server] -m [Mutual Exclusive] -n [Experiment Numbers] -o [File Name for storing experiments] -p [Page Name Prefix] -s [Experiment Start Value] ..." 2>&1
      exit 1
      ;;
  esac
done

rm -rf ${output_file} && touch ${output_file}
next_counter=0
exp_list=""
while [ ${next_counter} -lt ${number_of_experiment} ];
do
  echo ${next_counter} ${start_value}
  pos=`expr ${next_counter} + ${start_value}`
  echo "pos = " ${pos}
  exp_label="${exp_name_prefix}_${pos}"
  # Create an experiment with given exp_label and app_name
  echo curl -u jabba@intuit.com:jabba01 -H'Content-Type: application/json' -X POST -d '{"startTime": "2015-01-01T00:00:01Z", "endTime": "2019-01-01T00:00:01Z", "isPersonalizationEnabled": false, "label": "'"${exp_label}"'", "samplingPercent": 1.0, "applicationName": "'"${app_name}"'"}' http://${host}/api/v1/experiments
  exp_id=$(curl -u jabba@intuit.com:jabba01 -H'Content-Type: application/json' -X POST -d '{"startTime": "2015-01-01T00:00:01Z", "endTime": "2019-01-01T00:00:01Z", "isPersonalizationEnabled": false, "label": "'"${exp_label}"'", "samplingPercent": 1.0, "applicationName": "'"${app_name}"'"}' http://${host}/api/v1/experiments | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["id"]')
  echo ${exp_id}
  # expected exp_id should be something like ca0f5d8c-47be-40f1-a0d6-a2afdaeac566
  if [[ ! ${exp_id} =~ [0-9a-z]{8,8}-[0-9a-z]{4,4}-[0-9a-z]{4,4}-[0-9a-z]{4,4}-[0-9a-z]{12,12} ]]; then
    echo "Invalid experiment id, terminating tests."
    exit 1
  fi
  # Save app_name, exp_id and exp_label for cleaning up.
  echo ${app_name} ${exp_id} "${exp_label}" >> ${output_file}

  # Create two buckets for created experiment.
  echo curl -u jabba@intuit.com:jabba01 -H'Content-Type: application/json' -X POST -d '{"label": "controlbucket", "allocationPercent": 0.50, "isControl": true}' http://${host}/api/v1/experiments/${exp_id}/buckets
  curl -u jabba@intuit.com:jabba01 -H'Content-Type: application/json' -X POST -d '{"label": "controlbucket", "allocationPercent": 0.50, "isControl": true}' http://${host}/api/v1/experiments/${exp_id}/buckets
  echo curl -u jabba@intuit.com:jabba01 -H'Content-Type: application/json' -X POST -d '{"label": "testbucket", "allocationPercent": 0.50, "isControl": false}' http://${host}/api/v1/experiments/${exp_id}/buckets
  curl -u jabba@intuit.com:jabba01 -H'Content-Type: application/json' -X POST -d '{"label": "testbucket", "allocationPercent": 0.50, "isControl": false}' http://${host}/api/v1/experiments/${exp_id}/buckets
  # Set experiment state as running.
  echo curl -u jabba@intuit.com:jabba01 -H'Content-Type: application/json' -X PUT -d '{"state": "RUNNING"}' http://${host}/api/v1/experiments/${exp_id}
  curl -u jabba@intuit.com:jabba01 -H'Content-Type: application/json' -X PUT -d '{"state": "RUNNING"}' http://${host}/api/v1/experiments/${exp_id}
  # Set page name if page name is given.
  if [ -n "${page_name}" ]; then
    echo curl -u jabba@intuit.com:jabba01 -H'Content-Type: application/json' -X POST -d '{"pages" : [{"name": "'"${page_name}"'", "allowNewAssignment": true}]}' http://${host}/api/v1/experiments/${exp_id}/pages
    curl -u jabba@intuit.com:jabba01 -H'Content-Type: application/json' -X POST -d '{"pages" : [{"name": "'"${page_name}"'", "allowNewAssignment": true}]}' http://${host}/api/v1/experiments/${exp_id}/pages
  fi
  # Backup exp list for setting mutual exclusion for each other when mutual_exclusive is true.
  if [ "${mutual_exclusive}" == "true" ]; then
    if [ ${next_counter} -eq 0 ]; then
      first_exp_id="${exp_id}"
    elif [ "${exp_list}" == "" ]; then
      exp_list="${exp_id}"
    else
      exp_list="${exp_list}\",\"${exp_id}"
    fi
  fi
  next_counter=`expr ${next_counter} + 1`
done

# Set mutual exclusion between experiments.
if [  "${mutual_exclusive}" == "true" ]; then
  if [ ${number_of_experiment} -gt 1 ]; then
    echo ${exp_list}
    curl -u jabba@intuit.com:jabba01 -H'Content-Type: application/json' -X POST -d '{"experimentIDs": ["'"${exp_list}"'"]}' http://${host}/api/v1/experiments/${first_exp_id}/exclusions
  fi
fi
