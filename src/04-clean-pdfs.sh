#! bin/bash

sed 's/  */ /g' test.txt> test2.txt
sed 's/^$/d/g' test2.txt

awk '{print $1,$2, $3, $4}' test2.txt
