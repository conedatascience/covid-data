### clean up covid-data/data folder
# goal: only have 1 file per day per metric, keeping the latest we created
library(dplyr)
library(tidyr)
folders <- list.dirs(here::here('data'))
for(f in folders){
  files <- setdiff(list.files(f), list.dirs(f, recursive = FALSE, full.names = FALSE))
  reviewfiles <- files[grepl('^\\d{12}', files)]

  if(length(reviewfiles)>0){

    a <- tibble(filename = reviewfiles) %>%
      separate(filename,into = c('date', 'group'),
               sep='_', extra = 'merge',remove = FALSE) %>%
      separate(date,into = c('date', 'time'),
               sep=8) %>%
      group_by(group, date) %>%
      arrange(desc(time)) %>%
      mutate(linenbr = seq_along(time),
             keep = linenbr==1)

    to_delete <- a %>% filter(!keep)
    if(nrow(to_delete)>0){
      files_to_delete <- file.path(f, to_delete$filename)
      unlink(files_to_delete)
    }
    rm(a, to_delete, files_to_delete)
  }

  rm(files, reviewfiles)
}
