library(dplyr)
library(data.table)
# raw data location -------------------------------------------------------

data_dir <- fs::dir_ls(here::here("data", "daily-vax-providers"),  glob = "*csv")

# import data -------------------------------------------------------------

dat_raw <- purrr::map_dfr(data_dir, data.table::fread, .id = "date_pulled")

setDT(dat_raw)

dat_raw[, update_date := gsub(pattern = "([0-9]+).*$", "\\1",basename(date_pulled))]

dat_raw[, update_date := as.POSIXct(update_date, format = "%Y%m%d%H%M")]

dat_raw[, update_date_date := lubridate::date(update_date)]

# max data by date -------------------------------------------------------------

dat_latest <- dat_raw[dat_raw[, .I[update_date == max(update_date)], by=c("OBJECTID","update_date_date")]$V1]

dat_latest <- dat_latest[order(update_date_date)]

# Write Outputs

data.table::fwrite(dat_latest, here::here("data", "timeseries","vax-providers.csv"))