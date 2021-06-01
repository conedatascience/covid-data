library(dplyr)
library(data.table)
# raw data location -------------------------------------------------------

data_dir <- fs::dir_ls(here::here("data", "daily-vax-census"),  glob = "*csv")

# import data -------------------------------------------------------------

dat_raw <- purrr::map_dfr(data_dir, data.table::fread, .id = "date_pulled")

setDT(dat_raw)

dat_raw[, update_date := gsub(pattern = "([0-9]+).*$", "\\1",basename(date_pulled))]

dat_raw[, update_date := as.POSIXct(update_date, format = "%Y%m%d%H%M")]

dat_raw[, update_date_date := lubridate::date(update_date)]

# max data by date -------------------------------------------------------------

dat_latest <- dat_raw[dat_raw[, .I[update_date == max(update_date)], by=c("GEOID10","update_date_date")]$V1]

dat_latest <- dat_latest[order(update_date_date)]

dat_latest <- dat_latest[order(update_date_date),delta_vaccinated:=TotalVax-dplyr::lag(TotalVax,1, default = 0 ), by = "GEOID10"]

dat_latest_out = dat_latest[,c("NAME10", "OBJECTID", "COUNTYFP10", "GEOID10",

                      "TotalVax", "delta_vaccinated","TotalPop", "PctTotal", "Pop18Up", "Pop16Up", "Pop12Up",
                      "update_date_date")]

names(dat_latest_out) <- c("county", "objectid","county_fips", "geoid",
"total_vax", "new_vax","total_population", "percent_total", "pop_18_up", "pop_16_up", "pop_12_up",
"update_dts")

# Write Outputs

data.table::fwrite(dat_latest_out, here::here("data", "timeseries","vax-census.csv"))