#! bin/bash

sed 's/    */\t/g' test.txt> test2.txt

awk '$1 ~ /Demographics|Race|Missing|Cases|Age|Gender/ {next} {print}' test2.txt | awk '$1 ~ /Pacific|Ethnicity|Alaska/ {next} {print}' > test3.txt

awk 'NR==1{c=$0} !/^\t/{print c; c=$0} /^\t/{c=c ""$0} END{print c}' test3.txt | grep "[0-9]" > "demos_final.txt"

#awk '{print $0}' demos_final.txt

rm test2.txt test3.txt
