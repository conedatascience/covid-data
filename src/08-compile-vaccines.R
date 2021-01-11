# Consolidate Vaccination Records for North Carolina
library(dplyr)
library(data.table)

# raw data locations ------------------------------------------------------

data_dir <- fs::dir_ls(here::here("data", "daily-vax"), glob = "*xlsx")

# import data -------------------------------------------------------------

dat_raw <- purrr::map_dfr(data_dir,
                          ~readxl::read_excel(.x, skip = 3, sheet = 2,
                                              col_names = c("county", "vaccine_status", "total_doses")),
                           .id = "date_pulled"
                          )
setDT(dat_raw)

dat_raw[, update_date := gsub(pattern = "([0-9]+).*$", "\\1",basename(date_pulled))]

dat_raw[, update_date := as.POSIXct(update_date, format = "%Y%m%d%H%M")]

dat_raw[,county:= stringr::str_remove(string = county, "County")]

first_dist <- as.Date("2020-12-14")

dat_raw[,county:= stringr::str_remove(string = county, "County")]

report_date <- purrr::map_dfr(data_dir,
                              ~readxl::read_excel(.x, range = "A1:A1", sheet = 2,
                                                  col_names = c("date")),
                              .id = "date_pulled"
)

setDT(report_date)

report_date[, update_date := gsub(pattern = "([0-9]+).*$", "\\1",basename(date_pulled))]

report_date[, update_date := as.POSIXct(update_date, format = "%Y%m%d%H%M")]

report_date[,reported_date:=stringr::str_extract(date, pattern = "(\\D{3}\\. \\d{1}|\\d{2})")]

report_date[,reported_date:=lubridate::mdy(paste0(reported_date, " 2021"))]

report_date <- report_date[,c("reported_date", "date_pulled")]
# join information together -----------------------------------------------

dat_raw <- merge(dat_raw, report_date, by = "date_pulled", all.x = TRUE)

# diffing -----------------------------------------------------------------

dat_raw[ ,date:= lubridate::date(update_date)]

dat_latest <- dat_raw[update_date==max(update_date), , by = "date"]

dat_latest <- dcast(formula = date+reported_date+county~vaccine_status, value.var = "total_doses", data = dat_latest)

names(dat_latest) <- c("date", "reported_date","county", "dose_1", "dose_2")

dat_latest[order(date),`:=` (daily_dose_1 = dose_1 - shift(dose_1,1, fill = 0),
                  daily_dose_2 = dose_2 - shift(dose_2,1, fill = 0)), by = "county"]

days_avail <- as.numeric(Sys.Date()-first_dist)

dat_latest[,days_available:=ifelse(date==min(date),days_avail,date-shift(date,1,0)), by = "county"]

# write output ------------------------------------------------------------

data.table::fwrite(dat_latest, here::here("data", "timeseries", "nc-vaccinations.csv"))
