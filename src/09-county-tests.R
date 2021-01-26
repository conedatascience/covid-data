# Purpose: Clean County Tests
in_files <- fs::dir_info(file.path("data", "county-testing"), glob = "*.xlsx")

latest_file <-in_files[in_files$modification_time==max(in_files$modification_time)][["path"]]

in_raw <- readxl::read_excel(latest_file)

names(in_raw) <- c("county", "date","num_tests", "num_positive", "num_negative", "perc_positive")

in_raw$county <- trimws(stringr::str_remove(in_raw$county, " County"), which = "both")

data.table::fwrite(in_raw, here::here("data", "timeseries", "testing-by-county.csv"))
