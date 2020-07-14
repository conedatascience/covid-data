setwd("C:/Users/54011/Documents/pandemic/covid-data")

try(source("src/04-clean-pdfs.R"))

cmd_cd <- glue::glue("git add .")

system(cmd_cd)

cmd_cd <- glue::glue("git commit -m 'auto-update'")

system(cmd_cd)

system("git push origin master")
