#!/bin/sh


rm vertices.csv

i=1
while [ ${i} -le 50 ];
do
  cat vertices_ids.json >> vertices.csv
  i=`expr ${i} + 1`
done
