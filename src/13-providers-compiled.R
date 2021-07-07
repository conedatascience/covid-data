library(dplyr)
library(data.table)
# raw data location -------------------------------------------------------

data_dir <- fs::dir_ls(here::here("data", "daily-vax-providers"),  glob = "*csv")

# import data -------------------------------------------------------------


read_valid <- function(x){
    o <- data.table::fread(x)

    rcnt <- nrow(o)

    search_for_these <- c( "COVID_19VaccinationProviderType", "V1", "V2")
    replace_with_these <- c("ProviderType", "X", "Y")
    i1 <- match(colnames(o), search_for_these, nomatch = 0)
    
    colnames(o)[i1] <- replace_with_these[i1]

    if(rcnt>1){
        o
    } else {
        NULL
    }

}

#dat_raw <- rbindlist(lapply(data_dir, data.table::fread),  idcol = "date_pulled", fill = TRUE)

dat_raw <- rbindlist(lapply(data_dir,read_valid),  idcol = "date_pulled", fill = TRUE)

setDT(dat_raw)

dat_raw[, update_date := gsub(pattern = "([0-9]+).*$", "\\1",basename(date_pulled))]

dat_raw[, update_date := as.POSIXct(update_date, format = "%Y%m%d%H%M")]

dat_raw[, update_date_date := lubridate::date(update_date)]

# max data by date -------------------------------------------------------------

dat_latest <- dat_raw[dat_raw[, .I[update_date == max(update_date)], by=c("OBJECTID","update_date_date")]$V1]

dat_latest <- dat_latest[order(update_date_date)]

dat_latest[,POINT_X:=NULL]
dat_latest[,POINT_Y:=NULL]
dat_latest[,V1:=NULL]
dat_latest[,V2:=NULL]
dat_latest[,SysKey:=NULL]

# Write Outputs

data.table::fwrite(dat_latest, here::here("data", "timeseries","vax-providers.csv"))