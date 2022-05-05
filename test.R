
src_files <-  fs::dir_ls(path = here::here("src"), glob = "*.R")

print(Sys.getenv('edw_dsn_default'))
print(Sys.getenv('EDW_DSN_DEFAULT'))
print(Sys.getenv('R_HOME'))
print(Sys.getenv('R_USER'))

