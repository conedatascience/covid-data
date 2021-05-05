# Fix Some Errors

library(tidyverse)

target_files <- read_csv("file-mv.txt",     col_names = "target")

for(i in 1:nrow(target_files)){
    target_path <- file.path("daily-scrape",target_files$target[i] )

    dat_raw <- readr::read_csv(target_path)

    names(dat_raw) <- c("Deaths", "Casesper10k", "Casesper100k", "County", "Total")

    dat_raw$PctPos <- NA

  new_path <- file.path("covid-data", "data", "daily", target_files$target[i])
    write_csv(dat_raw, new_path)
}
