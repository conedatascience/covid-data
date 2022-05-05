
src_files <-  fs::dir_ls(path = here::here("src"), glob = "*.R")

print(Sys.getenv('edw_dsn_default'))

