#setwd("C:/Users/54011/Documents/pandemic/covid-data")
src_files <-  fs::dir_ls(path = here::here("src"), glob = "*.R")

cmd <- glue::glue("Rscript --vanilla {src_files}")

for(i in seq_along(cmd)){
    system(cmd[i])
}

system("git add --all")

gert::git_commit(glue::glue("Lastest update at {Sys.time()}"))