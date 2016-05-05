#!/bin/sh

OLDIFS=$IFS; IFS=","

while read employe_id v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18
do
   if [ "$v5" == "False" ];
   then
     echo "$employe_id,$v1,$v2,$v3,$v4,$v5,$v6,$v7,$v8,$v9,$v10,$v11,$v12,$v13,$v14,$v15,$v16,$v17,$v18"
   fi
done < $1

IFS=$OLDIFS
