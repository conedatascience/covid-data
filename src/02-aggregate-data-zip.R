library(dplyr)
library(data.table)
# raw data location -------------------------------------------------------

data_dir <- fs::dir_ls(here::here("data", "dailyzip"), glob = "*csv")

# import data -------------------------------------------------------------

dat_raw <- purrr::map_dfr(data_dir, data.table::fread, .id = "date_pulled")

setDT(dat_raw)

dat_raw[, update_date := gsub(pattern = "([0-9]+).*$", "\\1",basename(date_pulled))]

dat_raw[, update_date := as.POSIXct(update_date, format = "%Y%m%d%H%M")]

# move together -----------------------------------------------------------

dat_raw[ ,date:= lubridate::date(update_date)]

dat_raw_cleaned <- dat_raw %>%
  dplyr::select(ZIPCode, Place, date, Cases, Deaths, TotalPop) %>%
  dplyr::distinct() %>%
  dplyr::group_by(ZIPCode, date) %>%
  dplyr::filter(Cases == max(Cases)) %>%
  dplyr::ungroup() %>%
  dplyr::group_by(ZIPCode) %>%
  dplyr::mutate(cases_daily = Cases - dplyr::lag(Cases,n = 1, default = 0),
         deaths_daily = Deaths - dplyr::lag(Deaths,n = 1, default = 0)) %>%
  dplyr::mutate(cases_daily = ifelse(cases_daily<0, 0, cases_daily),
                deaths_daily = ifelse(deaths_daily<0, 0, deaths_daily))


# Fix Thanksgiving zero reports

dates_correct <- dat_raw_cleaned %>%
  dplyr::filter(date == as.Date("2020-11-27")) %>%
  dplyr::mutate(cases_daily = round(cases_daily/2),
                deaths_daily = round(deaths_daily/2))

dates_correct_out <- dplyr::bind_rows(dates_correct,
                                      dates_correct %>% mutate(date = as.Date("2020-11-26")))

dat_raw_cleaned <- dat_raw_cleaned %>%
  dplyr::filter(!date %in% c(as.Date("2020-11-26"), as.Date("2020-11-27"))) %>%
  dplyr::bind_rows(dates_correct_out)

dat_agg <- dat_raw_cleaned %>%
  dplyr::mutate(state = "North Carolina") %>%
  dplyr::rename(
    deaths_confirmed_cum = Deaths,
    cases_confirmed_cum = Cases
  ) %>%
  dplyr::mutate(cases_per_100k = cases_confirmed_cum/(TotalPop/100000))

cat("Latest Date:", format(max(dat_agg$date), "%B-%d"))
cat("Earliest Date:", format(min(dat_agg$date), "%B-%d"))

# combine with global tracking --------------------------------------------

# check to see if today's data are available
new_daily_cases <- dat_agg %>%
  dplyr::ungroup() %>%
  dplyr::filter(date == Sys.Date()) %>%
  summarise(new_cases = sum(cases_daily)) %>%
  dplyr::pull(new_cases)





dat_complete <- dat_agg
# If no county has any new cases (unlikely at this point)
# Then remove today's values.

if(new_daily_cases==0){
  dat_complete <- dat_complete %>%
    dplyr::filter(date < Sys.Date())
  cat("Today's data are not yet available.")
}

cat("Latest Date:", format(max(dat_complete$date), "%B-%d"))
cat("Earliest Date:", format(min(dat_complete$date), "%B-%d"))

# write output ------------------------------------------------------------

data.table::fwrite(dat_complete, here::here("data", "timeseries","nc-cases-by-zip.csv"))
