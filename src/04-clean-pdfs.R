library(data.table)
library(dplyr)


# bring in files and select oldest by date --------------------------------
in_files <- fs::dir_info(file.path("data", "daily-race"), glob = "*.pdf")

in_files <- in_files %>%
  mutate(date = lubridate::date(birth_time)) %>%
  group_by(date) %>%
  filter(birth_time==max(birth_time))

in_pdf <- lapply(in_files%>%
                   pull(path), pdftools::pdf_text)

names(in_pdf) <- in_files %>% pull(date)


# run processing ----------------------------------------------------------

# Read in files, run shell script, then clean up
process_pdfs <- function(x){
  writeLines(x, "test.txt")

  path <- file.path("src", "04-clean-pdfs.sh")
  call <- sprintf("bash %s", path)

  system(call)

  df <- data.table::fread("demos_final.txt",file = TRUE,
                          header = FALSE,
                          col.names = c("metric", "cases",
                                        "perc_of_cases",
                                        "deaths", "perc_of_deaths"))

  # Clean Up

  df[, `:=` (cases = readr::parse_number(cases),
             perc_of_cases= readr::parse_number(cases),
             deaths= readr::parse_number(deaths),
             perc_of_deaths= readr::parse_number(perc_of_deaths))] %>%
    .[,category := ifelse(grepl("[[:digit:]]", metric), "age",
                          ifelse(grepl("Hispanic", metric), "ethnicity",
                                 ifelse(grepl("ale", metric),"sex","race")))]
}

combined_data <- purrr::map_dfr(in_pdf, process_pdfs, .id = "date")


# write outputs -----------------------------------------------------------

data.table::fwrite(combined_data, here::here("data", "timeseries", "nc-demographics.csv"))
