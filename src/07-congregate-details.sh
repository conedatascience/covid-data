#! bin/bash
echo "sed worked"
awk '!/Congregate/' test.txt | awk '!/NC Department/' | \
awk '!/Staff/' | \
awk '!/Facility/' | \
awk '!/Case/' | \
awk '!/Case/' | \
awk '!/AB37/' | \
awk '!/outbreaks/' | \
awk '!/Setting/' | \
awk '!/COVID-19/' | \
awk '!/was published/' | \
awk '!/*/' | \
sed 's/    */;/g' > test2.txt

grep -E '[0-9]+' test2.txt > test3.txt
