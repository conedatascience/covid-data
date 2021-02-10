# Consolidate Vaccination Records for North Carolina
library(dplyr)
library(data.table)

# raw data locations ------------------------------------------------------

data_dir <- fs::dir_ls(here::here("data", "daily-vax"), glob = "*xlsx")

# import data -------------------------------------------------------------

dat_raw <- purrr::map_dfr(data_dir,
                          ~readxl::read_excel(.x, skip = 3, sheet = 2,range = "A4:C205",
                                              col_names = c("county", "vaccine_status", "total_doses")),
                           .id = "date_pulled"
                          )
setDT(dat_raw)

dat_raw <- dat_raw[!is.na(total_doses)]

dat_raw <- dat_raw[vaccine_status!= "Vaccine Status"]

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

report_date[,reported_date:=stringr::str_extract(date, pattern = "(\\D{3}\\. \\d{1,2})")]

report_date[,reported_date:=lubridate::mdy(paste0(reported_date, " 2021"))]

report_date <- report_date[,c("reported_date", "date_pulled")]
# join information together -----------------------------------------------

dat_raw <- merge(dat_raw[!is.na(total_doses)], report_date, by = "date_pulled", all.x = TRUE)

# diffing -----------------------------------------------------------------
debug <- FALSE

if(debug){
  dat_raw <- dat_raw[county=="Alamance"]
}

dat_raw[ ,date:= lubridate::date(reported_date)]

dat_latest <- dat_raw[,.(county,vaccine_status,total_doses,date)] %>%
  .[order(county,date)] %>%
  .[,head(.SD,1), by = c("county", "date", "vaccine_status")]

dat_latest <- dcast(formula = date+county~vaccine_status, value.var = "total_doses", data = dat_latest)

names(dat_latest) <- c("date","county", "dose_1", "dose_2")

dat_raw$dose_1 <- as.numeric(dat_raw$dose_1)
dat_raw$dose_2 <- as.numeric(dat_raw$dose_2)

dat_latest[order(date),`:=` (daily_dose_1 = dose_1 - data.table::shift(dose_1,1, fill = 0),
                  daily_dose_2 = dose_2 - data.table::shift(dose_2,1, fill = 0)), by = "county"]

days_avail <- as.numeric(min(dat_latest$date)-first_dist)

dat_latest[,days_available:=ifelse(date==min(date),days_avail,date-data.table::shift(date,1,0)), by = "county"]


# add in csv version of files ---------------------------------------------



# bringing it back together -----------------------------------------------

dat_latest[,cum_days:=cumsum(days_available), by = "county"]

dat_latest[,`:=` (
  dose_1_rate = daily_dose_1/days_available,
  dose_2_rate = daily_dose_2/days_available,
  dose_1_running_rate = dose_1/ cum_days,
  dose_2_running_rate = dose_2/ cum_days
)]

# write output ------------------------------------------------------------

data.table::fwrite(dat_latest, here::here("data", "timeseries", "nc-vaccinations.csv"))
# library(ggplot2)
# dat_latest %>%
#   left_join(nccovid::nc_population[,1:2], by = c("county" = "county")) %>%
#   filter(date==max(date)) %>%
#   mutate(per_cap_daily = dose_1_running_rate/(july_2020/100000)) %>%
#   filter(county != "Missing") %>%
#   left_join(nccovid::nc_hc_coalitions) %>%
#   .[county %in% nccovid::cone_region] %>%
#   ggplot(aes(reorder(county,per_cap_daily), per_cap_daily, colour = coalition))+
#   geom_point()+
#   coord_flip()+
#   theme_minimal()+
#   eastyle::theme_cone()+
#   labs(
#     title = "Vaccine Shots in Arms in NC",
#     y = "Dose 1 per Day per 100k Residents",
#     x = NULL
#   )
