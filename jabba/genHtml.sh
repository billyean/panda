#!/bin/sh

html_file="${1}.html"

rm ${html_file}

echo "<html>" >> ${html_file}
echo "<head>" >> ${html_file}
echo "<title>" >> ${html_file}
echo "Performance test" ${html_file}
echo "</title>" >> ${html_file}
echo "</head>" >> ${html_file}
echo "<body>" >> ${html_file} 

while read line
do
  echo ${line} >> ${html_file}
done < ${0}

echo "</body>" >> ${html_file}
echo "</html>" >> ${html_file}
