library(data.table)
library(dplyr)

cat("Starting Daily Metrics Scrapes\n\n")
# bring in files and select oldest by date --------------------------------
in_files <- fs::dir_info(file.path("data", "daily-metrics"), glob = "*.csv")


in_files$update_date <- gsub(pattern = "([0-9]+).*$", "\\1",basename(in_files$path))

in_files$update_date <- as.POSIXct(in_files$update_date, format = "%Y%m%d%H%M")

in_files$update_date_only <- lubridate::date(in_files$update_date)

in_files <- in_files %>%
  dplyr::group_by(update_date_only) %>%
  dplyr::filter(update_date==max(update_date)) %>%
  slice(1) %>%
  ungroup()

in_data <- lapply(in_files$path, data.table::fread)

names(in_data) <- in_files$update_date_only

in_data[[1]] <- NULL

in_data <- rbindlist(in_data, idcol = "update_date")

# clean up values ---------------------------------------------------------

out_data <- in_data[,update_date:=as.Date(update_date)] %>%
  .[,Date:=lubridate::mdy(Date)] %>%
  .[,`Measure Values`:=readr::parse_number(`Measure Values`)] %>%
  setNames(c("update_date", "date", "measure", "value"))

out_data_latest <- out_data[update_date==max(update_date)]

out_data_long <- dcast(out_data, date~measure, value.var = "value", fill = NA, fun.aggregate = function(x) x)

names(out_data_long) <- c("date", "hospitalizations",
                          "daily_tests", "daily_cases",
                          "daily_specimen", "positive_tests",
                          "sum_hospitalizations")


# write output ------------------------------------------------------------

data.table::fwrite(out_data_long, here::here("data", "timeseries", "nc-summary-stats.csv"))

