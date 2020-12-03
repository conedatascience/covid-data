library(data.table)
library(dplyr)

cat("Starting Pdf Scrapes\n\n")
# bring in files and select oldest by date --------------------------------
in_files <- fs::dir_info(file.path("data", "daily-race"), glob = "*.pdf")


in_files$update_date <- gsub(pattern = "([0-9]+).*$", "\\1",basename(in_files$path))

in_files$update_date <- as.POSIXct(in_files$update_date, format = "%Y%m%d%H%M")

in_files$update_date_only <- lubridate::date(in_files$update_date)

in_files <- in_files %>%
  dplyr::group_by(update_date_only) %>%
  dplyr::filter(update_date==max(update_date)) %>%
  slice(1) %>%
  ungroup()

in_pdf <- lapply(in_files%>%
                   dplyr::pull(path), pdftools::pdf_text)

names(in_pdf) <- in_files %>% pull(update_date_only)

cat(names(in_pdf))

# run processing ----------------------------------------------------------
cat(getwd())
# Read in files, run shell script, then clean up
process_pdfs <- function(x){
  xfun::write_utf8(x, "test.txt")

  path <- file.path("src", "04-clean-pdfs.sh")
  call <- sprintf("bash %s", path)

  cat("processing...\n")
  system(call)

  unlink("test.txt")


  df <- data.table::fread(here::here("demos_final.txt"),fill = TRUE,
                          header = FALSE,
                          col.names = c("metric", "cases",
                                        "perc_of_cases",
                                        "deaths", "perc_of_deaths"))

  unlink("demos_final.txt")
  #cat(head(df))
  # Clean Up

  df[, `:=` (cases = readr::parse_number(cases),
             perc_of_cases= readr::parse_number(perc_of_cases),
             deaths= readr::parse_number(deaths),
             perc_of_deaths= readr::parse_number(perc_of_deaths))] %>%
    .[,category := fifelse(grepl("[[:digit:]]", metric), "age",
                          fifelse(grepl("Hispanic", metric), "ethnicity",
                                 fifelse(grepl("ale", metric),"sex","race")))] %>%
    .[,metric := fifelse(grepl("Indian", x = metric),
                         "American Indian and Alaska Native", metric)] %>%
  .[,metric := fifelse(grepl("Hawaiian", x = metric),
                        "Native Hawaiian or Pacific Islander", metric)] %>%
    .[,metric := fifelse(grepl("Black", x = metric),
                        "Black or African American", metric)] %>%
  .[,metric:= gsub(pattern = "\\r+", "", metric)] %>%
    .[,category:= fifelse(metric %chin% c("Yes", "No"), "ethnicity", category)] %>%
    .[,metric :=fifelse(metric =="Yes", "Hispanic",
                        fifelse(metric=="No", "Non-Hispanic", metric))]

}

combined_data <- list()

for(i in 1:length(in_pdf)){
  cat("processing: ", i," out of ",length(in_pdf) , "\n")
  combined_data[[i]] <- process_pdfs(in_pdf[[i]])
}

#combined_data <- try(purrr::map_dfr(in_pdf, process_pdfs, .id = "date"))

names(combined_data) <- in_files %>% pull(update_date_only)

combined_data <- rbindlist(combined_data, idcol = TRUE)

combined_data <- combined_data[ , cases_daily:=cases - data.table::shift(cases, type = "lag"), by = metric]
combined_data <- combined_data[ , deaths_daily:=deaths - data.table::shift(deaths, type = "lag"), by = metric]

if(combined_data[.id==max(.id)][,sum(cases_daily)]==0|length(combined_data[.id==max(.id)][,sum(cases_daily)])){
  combined_data <- combined_data[.id!=max(.id)]
}



cat(nrow(combined_data))
# write outputs -----------------------------------------------------------

if(!"try-error"%in%class(combined_data)){
  data.table::fwrite(combined_data, here::here("data", "timeseries", "nc-demographics.csv"))

}
table(combined_data$metric)
