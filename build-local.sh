cd /mnct/resource/covid-data-store/covid-data

git pull origin master

R CMD BATCH --vanilla build.R

git add .
git commit -m "Update the latest data" -a || echo "No changes to commit"
git push origin master
