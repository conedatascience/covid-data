url <- "https://public.tableau.com/vizql/w/NCDHHS_COVID-19_DataDownload/v/DailyMetrics/vudcsv/sessions/A8345B6881C14C58AD041CCA152A16C2-0:0/views/4771422506905449664_9024048749190726675?underlying_table_id=Migrated%20Data&underlying_table_caption=Full%20Data"
current_time <- format(Sys.time(), "%Y%m%d%H%M")

try(download.file(url = url, destfile = here::here("data", "daily-metrics",
                                               paste0(current_time,"_ncdhss_metrics.csv"))))

