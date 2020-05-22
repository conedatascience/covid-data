src_files <-  fs::dir_ls(path = here::here("src"), glob = "*.R")

lapply(X = src_files, try(expr = source))
