

all:
	Rscript build.R
	git add .; git commit -m "auto-update"; git push origin master;

commit:
	git add .; git commit -m "auto-update"; git push origin master;
