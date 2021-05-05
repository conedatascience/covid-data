url <- "https://public.tableau.com/views/NCDHHS_COVID-19_DataDownload/DailyCasesandDeathsMetrics.csv?:embed=y&:showVizHome=no&:host_url=https%3A%2F%2Fpublic.tableau.com%2F&:embed_code_version=3&:tabs=yes&:toolbar=no&:animate_transition=yes&:display_static_image=no&:display_spinner=no&:display_overlay=yes&:display_count=no&publish=yes&:loadOrderID=0"
current_time <- format(Sys.time(), "%Y%m%d%H%M")
try(download.file(url = url, destfile = here::here("data", "daily-metrics",
                                               paste0(current_time,"_ncdhss_metrics.csv"))))
# Testing
url <- "https://public.tableau.com/views/NCDHHS_COVID-19_DataDownload/DailyTestingMetrics.csv?:embed=y&:showVizHome=no&:host_url=https%3A%2F%2Fpublic.tableau.com%2F&:embed_code_version=3&:tabs=yes&:toolbar=no&:animate_transition=yes&:display_static_image=no&:display_spinner=no&:display_overlay=yes&:display_count=no&publish=yes&:loadOrderID=0&:worksheet=TABLE_DAILY_TESTING_METRICS"
#url<- "https://public.tableau.com/vizql/w/NCDHHS_COVID-19_DataDownload/v/DailyTestingMetrics/vudcsv/sessions/08A22C7CF5DF404B9AA08FB6B780AA0F-0:0/views/18079243224349496428_12928853633925886214?underlying_table_id=Migrated%20Data&underlying_table_caption=Full%20Data"
try(metrics <-httr::content(httr::GET(url)))

try(data.table::fwrite(metrics, here::here("data", "daily-testing",
                                                   paste0(current_time,"_ncdhss_metrics.csv"))))
# age ---------------------------------------------------------------------

url <- "https://public.tableau.com/views/NCDHHS_COVID-19_DataDownload/Demographics.csv?%3Aembed=y&%3AshowVizHome=no&%3Ahost_url=https%3A%2F%2Fpublic.tableau.com%2F&%3Aembed_code_version=3&%3Aembed_code_version=3&%3Atabs=yes&%3Atabs=yes&%3Atoolbar=no&%3Atoolbar=no&%3Aanimate_transition=yes&%3Aanimate_transition=yes&%3Adisplay_static_image=no&%3Adisplay_static_image=no&%3Adisplay_spinner=no&%3Adisplay_spinner=no&%3Adisplay_overlay=yes&%3Adisplay_overlay=yes&%3Adisplay_count=no&%3Adisplay_count=no&publish=yes&publish=yes&%3AloadOrderID=0u.com%2F&%3AloadOrderID=0"

try(download.file(url = url, destfile = here::here("data", "daily-age",
                                                   paste0(current_time,"_ncdhss_age.csv"))))


# # race --------------------------------------------------------------------
#
url <- "https://public.tableau.com/views/NCDHHS_COVID-19_DataDownload/Demographics.pdf?%3Aembed=y&%3AshowVizHome=no&%3Ahost_url=https%3A%2F%2Fpublic.tableau.com%2F&%3Aembed_code_version=3&%3Aembed_code_version=3&%3Atabs=yes&%3Atabs=yes&%3Atoolbar=no&%3Atoolbar=no&%3Aanimate_transition=yes&%3Aanimate_transition=yes&%3Adisplay_static_image=no&%3Adisplay_static_image=no&%3Adisplay_spinner=no&%3Adisplay_spinner=no&%3Adisplay_overlay=yes&%3Adisplay_overlay=yes&%3Adisplay_count=no&%3Adisplay_count=no&publish=yes&publish=yes&%3AloadOrderID=0u.com%2F&%3AloadOrderID=0"

a <- rvest::html_session(url)
writeBin(a$response$content,here::here("data", "daily-race",
                                       paste0(current_time,"_ncdhss_race.pdf")))
# # ethnicity ---------------------------------------------------------------
#
# url <- "https://public.tableau.com/vizql/w/NCDHHS_COVID-19_DataDownload/v/Demographics/vudcsv/sessions/7D331135251941A49478767178E2F38C-0:0/views/5649504231100340473_5745676187720193715?showall=true&underlying_table_id=Migrated%20Data&underlying_table_caption=Full%20Data"
#
# try(download.file(url = url, destfile = here::here("data", "daily-eth",
#                                                    paste0(current_time,"_ncdhss_eth.csv"))))
#
#
# # gender ------------------------------------------------------------------
#
# url <- "https://public.tableau.com/vizql/w/NCDHHS_COVID-19_DataDownload/v/Demographics/vudcsv/sessions/7D331135251941A49478767178E2F38C-0:0/views/5649504231100340473_14942902393317967217?showall=true&underlying_table_id=Migrated%20Data&underlying_table_caption=Full%20Data"
#
# try(download.file(url = url, destfile = here::here("data", "daily-sex",
#                                                    paste0(current_time,"_ncdhss_sex.csv"))))


# beds and vents ----------------------------------------------------------

url <- "https://public.tableau.com/views/NCDHHS_COVID-19_DataDownload/HospitalBeds.csv?%3Aembed=y&%3AshowVizHome=no&%3Ahost_url=https%3A%2F%2Fpublic.tableau.com%2F&%3Aembed_code_version=3&%3Aembed_code_version=3&%3Atabs=yes&%3Atabs=yes&%3Atoolbar=no&%3Atoolbar=no&%3Aanimate_transition=yes&%3Aanimate_transition=yes&%3Adisplay_static_image=no&%3Adisplay_static_image=no&%3Adisplay_spinner=no&%3Adisplay_spinner=no&%3Adisplay_overlay=yes&%3Adisplay_overlay=yes&%3Adisplay_count=no&%3Adisplay_count=no&publish=yes&publish=yes&%3AloadOrderID=0u.com%2F&%3AloadOrderID=0"

try(download.file(url = url, destfile = here::here("data", "daily-beds",
                                                   paste0(current_time,"_ncdhss_beds.csv"))))


# outbreaks ---------------------------------------------------------------

url <- "https://public.tableau.com/views/NCDHHS_COVID-19_Dashboard_OutbreaksandClusters/NCDHHS_COVID-19_Dashboard_OutbreaksandClusters.pdf?:language=en&:embed=y&:embed_code_version=3&:loadOrderID=0&:display_count=y&publish=yes&:origin=viz_share_link&:showVizHome=no"

a <- rvest::html_session(url)
writeBin(a$response$content,here::here("data", "daily-outbreaks",
                                       paste0(current_time,"_ncdhss_outbreaks.pdf")))
## Weekly Outbreaks
url <- "https://files.nc.gov/ncdhhs/documents/files/covid-19/Weekly-COVID19-Ongoing-Outbreaks.pdf"
a <- rvest::html_session(url)
writeBin(a$response$content,here::here("data", "daily-outbreaks", "report",
                                       paste0(current_time,"_ncdhss_outbreak_report.pdf")))
## Weekly Childcare
url <- "https://files.nc.gov/covid/documents/dashboard/Weekly-Ongoing-Clusters-in-Child-Care-and-School-Settings.pdf"
a <- rvest::html_session(url)
writeBin(a$response$content,here::here("data", "daily-outbreaks", "schools",
                                       paste0(current_time,"_ncdhss_school_report.pdf")))
# detailed patient data ---------------------------------------------------


## Pull
#url <- "https://public.tableau.com/vizql/w/NCDHHS_COVID-19_DataDownload/v/HospitalPatientData/vudcsv/sessions/48357CE83FD24F04AC0BD68C3874BECE-0:0/views/4022802588106640556_9307479125736770152?showall=true&underlying_table_id=medsurge_public_facing.csv_9E85D41A33ED4AAE941D68C3B611FF90&underlying_table_caption=Full%20Data"
#try(download.file(url = url, destfile = here::here("data", "daily-patient",
#                                                   paste0(current_time,"_ncdhss_age.csv"))))

# new county demographics -------------------------------------------------

# url <- "https://public.tableau.com/views/NCDHHS_COVID-19_DataDownload/CountyDemographics.csv?%3Aembed=y&%3AshowVizHome=no&%3Ahost_url=https%3A%2F%2Fpublic.tableau.com%2F&%3Aembed_code_version=3&%3Aembed_code_version=3&%3Atabs=yes&%3Atabs=yes&%3Atoolbar=no&%3Atoolbar=no&%3Aanimate_transition=yes&%3Aanimate_transition=yes&%3Adisplay_static_image=no&%3Adisplay_static_image=no&%3Adisplay_spinner=no&%3Adisplay_spinner=no&%3Adisplay_overlay=yes&%3Adisplay_overlay=yes&%3Adisplay_count=no&%3Adisplay_count=no&publish=yes&publish=yes&%3AloadOrderID=0u.com%2F&%3AloadOrderID=0"
#
# try(download.file(url = url, destfile = here::here("data", "county-detail",
#                                                    paste0(current_time,"_ncdhss_age.csv"))))
#


# vaccinations rollouts ---------------------------------------------------


# ## Pull
# url <- "https://files.nc.gov/covid/documents/dashboard/Vaccinations_Dashboard_Data.xlsx"
# try(download.file(url = url, destfile = here::here("data", "daily-vax",
#                                                    paste0(current_time,"_ncdhss_vax.xlsx")),
#                   mode = "wb"))

