
library(dplyr)
library(data.table)

# raw data location ------------------------------------------------------

file_loc <- here::here('data', 'timeseries', 'nc-summary-all-vaccine.csv')

# import data -------------------------------------------------------------

dat_raw <- data.table::fread(file_loc)

# clean data -------------------------------------------------------------
setDT(dat_raw)
dat_raw <- dat_raw[!is.na(`Week of`) & `Data Source`=='All Programs']
cols <- sapply(dat_raw, function(x)!all(is.na(x)))
cols <- names(cols)[cols]
dat_raw <- dat_raw[,..cols]

# **needed to move this upstream for push after UpdateNCDHHSDashboard dag**
# reduce original file size (hitting some size issues)
data.table::fwrite(dat_raw, file_loc)
