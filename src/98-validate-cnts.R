# Purpose:
# Occasionally the state will put out some weird values (e.g., 2021-06-29 through 2021-06-30 
# had abnormally low then high deaths reported)
# If some criteria (e.g., deaths reported on a day greater than 20x the 7 day sum, the a placeholder is added.)
# This does some sanity checking to ensure that logical death and case values are report
library(data.table)

dat_raw <- fread( here::here("data", "timeseries","nc-cases-by-county.csv"))

starting_columns <- ncol(dat_raw)
starting_rows <- nrow(dat_raw)

dat_raw <- dat_raw[order(date)]

dat_raw[,case_lag:=dplyr::lag(frollsum(cases_daily, n = 7, fill =0), 1, default = 0), by = "county"]
dat_raw[,death_lag:=dplyr::lag(frollsum(deaths_daily, n = 7, fill =0), 1,default = 0), by = "county"]
dat_raw[county=="Guilford"][date>(Sys.Date()-10)]
# Run validation Scripts

dat_clean <- copy(dat_raw)

dat_clean[,deaths_daily:=fifelse(deaths_daily > 20 * death_lag, dplyr::lag(deaths_daily,1,default=0), deaths_daily), by = "county"]

#dat_clean[county=="Guilford"][date>(Sys.Date()-10)]

dat_clean[,deaths_confirmed_cum:= cumsum(deaths_daily), by = "county"]

dat_clean[,case_lag:=NULL]
dat_clean[,death_lag:=NULL]

data.table::fwrite(dat_clean, here::here("data", "timeseries","nc-cases-by-county.csv"))