#setwd("C:/Users/54011/Documents/pandemic/covid-data")
src_files <-  fs::dir_ls(path = here::here("src"), glob = "*.R")

cmd <- glue::glue("Rscript --vanilla {src_files}")

for(i in seq_along(cmd)){
    print(cmd[i])
    tmp <- system(cmd[i], intern=TRUE)
    if(!is.null(attributes(tmp))){
    	stop(glue::glue('Non-null attributes returned by command, script may have failed for cmd {cmd[i]}'))
    }
}

system("git add --all")
msg = glue::glue("Lastest update at {Sys.time()}")
# gert::git_commit(  msg)
system(glue::glue('git commit -m "{msg}"'))
# gert::git_push()
system('git push')
