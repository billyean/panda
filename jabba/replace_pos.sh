#!/b in/sh

pos_str=`grep -r "start_pos=" $1`
start_number=`echo ${pos_str} | cut -d"=" -f2`
new_number=${2}

if [ ${new_number} -gt 1000000 ];
then
  new_number=1001
fi

new_pos_str="start_pos=${new_number}"
sed -i -- "s/${pos_str}/${new_pos_str}/g" $1
