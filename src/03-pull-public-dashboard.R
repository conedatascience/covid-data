url <- "https://public.tableau.com/vizql/w/NCDHHS_COVID-19_DataDownload/v/DailyMetrics/vudcsv/sessions/60CEC09CA2284E74A01A2CE6903BA11F-0:0/views/4771422506905449664_9024048749190726675?showall=true&underlying_table_id=Migrated%20Data&underlying_table_caption=Full%20Data"
current_time <- format(Sys.time(), "%Y%m%d%H%M")

try(download.file(url = url, destfile = here::here("data", "daily-metrics",
                                               paste0(current_time,"_ncdhss_metrics.csv"))))


# age ---------------------------------------------------------------------

url <- "https://public.tableau.com/vizql/w/NCDHHS_COVID-19_DataDownload/v/Demographics/vudcsv/sessions/7D331135251941A49478767178E2F38C-0:0/views/5649504231100340473_6474227137836628765?showall=true&underlying_table_id=Migrated%20Data&underlying_table_caption=Full%20Data"

try(download.file(url = url, destfile = here::here("data", "daily-age",
                                                   paste0(current_time,"_ncdhss_age.csv"))))


# race --------------------------------------------------------------------

url <- "https://public.tableau.com/vizql/w/NCDHHS_COVID-19_DataDownload/v/Demographics/vudcsv/sessions/7D331135251941A49478767178E2F38C-0:0/views/5649504231100340473_15757585069639442359?showall=true&underlying_table_id=Migrated%20Data&underlying_table_caption=Full%20Data"

try(download.file(url = url, destfile = here::here("data", "daily-race",
                                                   paste0(current_time,"_ncdhss_race.csv"))))

# ethnicity ---------------------------------------------------------------

url <- "https://public.tableau.com/vizql/w/NCDHHS_COVID-19_DataDownload/v/Demographics/vudcsv/sessions/7D331135251941A49478767178E2F38C-0:0/views/5649504231100340473_5745676187720193715?showall=true&underlying_table_id=Migrated%20Data&underlying_table_caption=Full%20Data"

try(download.file(url = url, destfile = here::here("data", "daily-eth",
                                                   paste0(current_time,"_ncdhss_eth.csv"))))


# gender ------------------------------------------------------------------

url <- "https://public.tableau.com/vizql/w/NCDHHS_COVID-19_DataDownload/v/Demographics/vudcsv/sessions/7D331135251941A49478767178E2F38C-0:0/views/5649504231100340473_14942902393317967217?showall=true&underlying_table_id=Migrated%20Data&underlying_table_caption=Full%20Data"

try(download.file(url = url, destfile = here::here("data", "daily-sex",
                                                   paste0(current_time,"_ncdhss_sex.csv"))))


# beds and vents ----------------------------------------------------------

url <- "https://public.tableau.com/vizql/w/NCDHHS_COVID-19_DataDownload/v/HospitalBeds/vudcsv/sessions/7D331135251941A49478767178E2F38C-0:0/views/1140134203458450422_7087943268751700638?summary=true"

try(download.file(url = url, destfile = here::here("data", "daily-beds",
                                                   paste0(current_time,"_ncdhss_beds.csv"))))
