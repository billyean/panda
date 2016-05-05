#!/bin/sh

# Usage : sh deleteExperiments.sh [file name]
# by default file name is batch_list, but we can assign it with parameter
# file format : [application name] [experiment id] [experiment label]

if [ $$  -lt 1 ]; then
  echo "Usage : sh deleteExperiments.sh [file name]"
  exit 1
fi

exp_file=${1}

if [ -z ${host} ]; then
  host=internal-jabba-perf-ilb-1595286552.us-west-2.elb.amazonaws.com
fi
# Explicit using credential here because we maintain same user id/password all the time.
if [ -z ${user_credential} ]; then
  user_credential="jabba@intuit.com:jabba01"
fi

while read line;
do
  application_name=`echo ${line} | cut -d" " -f1`
  exp_id=`echo ${line} | cut -d" " -f2`
  exp_label=`echo ${line} | cut -d" " -f3`
  curl -u ${user_credential} -H'Content-Type: application/json' -X PUT -d '{"id": "'"${exp_id}"'", "label": "'"${exp_label}"'", "applicationName": "'"${application_name}"'",  "startTime": "2015-01-01T00:00:01Z", "endTime": "2019-01-01T00:00:01Z", "samplingPercent": 1.0, "ruleJson": "", "state": "TERMINATED", "isPersonalizationEnabled": false, "modelName": "", "modelVersion": "", "isRapidExperiment": false, "userCap": 0, "creatorID": "jabba@intuit.com"}' http://${host}/api/v1/experiments/${exp_id}
  curl -u ${user_credential} -X DELETE -H'Content-Type: application/json' http://${host}/api/v1/experiments/${exp_id}
  echo
  echo
done < ${exp_file}
