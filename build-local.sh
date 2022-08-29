set -e

cd /datadisk/covid-data-store/covid-data

git pull origin master

Rscript --vanilla build.R

## git add/commit/push is done in the build.R
# git add .
# git commit -m "Update the latest data" -a || echo "No changes to commit"
# #git push origin master
#
# #Rscript -e 'gert::git_push()'
# git push origin master

echo 'completed scrape'

