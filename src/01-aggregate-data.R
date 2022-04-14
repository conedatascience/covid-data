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

dat_state <- copy(dat_raw[ , c("date", "Hosp")])

dat_raw <- dat_raw[ , c("date", "County", "Total", "Deaths", "PctPos")]

dat_raw <- dat_raw[,County:= stringr::str_remove(string = County, "County")]

dat_raw <- dat_raw[,County := stringr::str_trim(County)]

# Bring in Earlier Cases

early_cases <- data.table::fread(here::here("data", "early_cases.csv"))

early_cases[, date := as.Date(date, format = "%m/%d/%Y")]

early_cases <- early_cases[,c("date", "county", "cases_confirmed_cum", "deaths_confirmed_cum")]

names(early_cases) <- c("date", "County", "Total", "Deaths")
early_cases$PctPos <- NA
dat_raw <- rbind(dat_raw, early_cases)

dat_raw <- dat_raw[dat_raw[,.I[which.max(Total)], by = c("date", "County")]$V1]

dat_raw_cleaned <- dat_raw %>%
  dplyr::group_by(County) %>%
  dplyr::mutate(cases = Total - dplyr::lag(Total,n = 1, default = 0),
         deaths = Deaths - dplyr::lag(Deaths,n = 1, default = 0)) %>%
  dplyr::mutate_at(vars(cases, deaths), function(x){ifelse(x<0,0,x)}) %>%
  dplyr::mutate(state = "North Carolina") %>%
  dplyr::select(state, County, date, cases, deaths, pct_pos = PctPos) %>%
  dplyr::mutate(pct_pos = pct_pos/100) %>%
  dplyr::rename(cases_daily = cases,
                deaths_daily = deaths,
                county = County)

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

dat_agg <- dat_raw_cleaned

cat("Latest Date:", format(max(dat_agg$date), "%B-%d"),"\n")
cat("Earliest Date:", format(min(dat_agg$date), "%B-%d"), "\n")

# combine with global tracking --------------------------------------------

dat_complete <- dat_agg %>%
  dplyr::group_by(county) %>%
  dplyr::arrange(date) %>%
  dplyr::mutate(cases_confirmed_cum = cumsum(cases_daily),
         deaths_confirmed_cum = cumsum(deaths_daily)) %>%
  dplyr::filter(!is.na(county))

# check to see if today's data are available
new_daily_cases <- dat_complete %>%
  dplyr::ungroup() %>%
  dplyr::filter(date == Sys.Date()) %>%
  summarise(new_cases = sum(cases_daily)) %>%
  dplyr::pull(new_cases)

# If no county has any new cases (unlikely at this point)
# Then remove today's values.

if(new_daily_cases==0){
  dat_complete <- dat_complete %>%
    dplyr::filter(date < Sys.Date())
  cat("Today's data are not yet available.")
}

cat("Latest Date:", format(max(dat_complete$date), "%B-%d"))
cat("Earliest Date:", format(min(dat_complete$date), "%B-%d"))

# with new weekly update, use the latest time series data in place of attempt at daily calculations
# that are no longer valid...

dat_new <- data.table::fread(here::here('data', 'timeseries', 'nc-cases-by-county-new.csv'))

dat_new <- dat_new %>%
  transmute(state = 'North Carolina',
            county = County,
            date = Date,
            cases_daily = `Total Cases by Date of Specimen collection`,
            deaths_daily = `Death by Date of Death`,
            pct_pos = NA) %>%
  filter(!is.na(county), !is.na(date))

dat_complete2 <- dat_complete %>% ungroup() %>%
  filter(date < min(dat_new$date)) %>%
  bind_rows(dat_new) %>%
  group_by(state, county) %>% arrange(date) %>%
  mutate(cases_confirmed_cum = cumsum(cases_daily),
         deaths_confirmed_cum = cumsum(deaths_daily))

# write output ------------------------------------------------------------

data.table::fwrite(dat_complete2, here::here("data", "timeseries","nc-cases-by-county.csv"))

