library(dplyr)
library(data.table)
# raw data location -------------------------------------------------------

data_dir <- fs::dir_ls(here::here("data", "daily"), glob = "*csv")

# import data -------------------------------------------------------------

dat_raw <- purrr::map_dfr(data_dir, data.table::fread, .id = "date_pulled")

setDT(dat_raw)

dat_raw[, update_date := gsub(pattern = "([0-9]+).*$", "\\1",basename(date_pulled))]

dat_raw[, update_date := as.POSIXct(update_date, format = "%Y%m%d%H%M")]

# move together -----------------------------------------------------------

dat_raw[ ,date:= lubridate::date(update_date)]

dat_raw_cleaned <- dat_raw %>%
  dplyr::select(County,date, update_date, Total, Deaths) %>%
  dplyr::distinct() %>%
  dplyr::group_by(County) %>%
  dplyr::mutate(Total = Total - dplyr::lag(Total,n = 1, default = 0),
         Deaths = Deaths - dplyr::lag(Deaths,n = 1, default = 0))

dat_agg <- dat_raw_cleaned %>%
  dplyr::group_by(County, date) %>%
  dplyr::summarise(cases = max(Total),
            deaths = max(Deaths)) %>%
  dplyr::rename(county = County) %>%
  dplyr::mutate(true_date = date - 1) %>%
  dplyr::filter(date != as.Date("2020-03-19")) %>%
  dplyr::select(-date) %>%
  dplyr::rename(date = true_date) %>%
  dplyr::mutate(state = "North Carolina") %>%
  dplyr::select(state, county, date, cases, deaths) %>%
  dplyr::rename(cases_daily = cases,
         deaths_daily = deaths) %>%
  dplyr::filter(date != as.Date("2020-05-11")) %>%
  dplyr::filter(date != as.Date("2020-04-29"))

early_cases <- data.table::fread(here::here("data", "early_cases.csv"))

early_cases[, date := as.Date(date, format = "%m/%d/%Y")]

early_cases <- early_cases[,c("date", "state", "county", "cases_daily", "deaths_daily")]

dat_agg <- dat_agg %>%
  dplyr::bind_rows(early_cases)

cat("Latest Date:", format(max(dat_agg$date), "%B-%d"))
cat("Earliest Date:", format(min(dat_agg$date), "%B-%d"))

# combine with global tracking --------------------------------------------

dat_complete <- dat_agg %>%
  dplyr::group_by(county, date) %>%
  dplyr::mutate(cases_confirmed_cum = cumsum(cases_daily),
         deaths_confirmed_cum = cumsum(deaths_daily))
# write output ------------------------------------------------------------

data.table::fwrite(dat_complete, here::here("data", "timeseries","nc-cases-by-county.csv"))
