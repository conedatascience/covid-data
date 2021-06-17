# Consolidate Vaccination Demographic Records for North Carolina
library(dplyr)
library(data.table)

# raw data location ------------------------------------------------------

data_dir <- fs::dir_ls(here::here("data", "vax-demos"), glob = "*csv")

#identify date of file
dir_dates <- gsub(pattern = "([0-9]+).*$", "\\1",basename(data_dir))
dir_dates <- as.Date(as.POSIXct(dir_dates, format = "%Y%m%d%H%M"))

#identify type of file
dd_fed <- grepl('dd_federal.csv',  data_dir, fixed = F)
dd_nc <- grepl('dd_nc.csv',  data_dir, fixed = F)

#only keep 1 file of each type per day
file_def <- data.frame(filename = data_dir,
                       filedate = dir_dates,
                       filetype = ifelse(dd_fed,'federal',
                                         ifelse(dd_nc,'nc',
                                                'old')))
file_keep <- file_def %>% group_by(filedate, filetype) %>% slice(1)

if(any(table(file_keep$filedate)>2)) stop('extra files found')
files_pull <- file_keep$filename
names(files_pull) <- files_pull

# import data -------------------------------------------------------------

dat_raw <- purrr::map_dfr(files_pull, data.table::fread, .id = "date_pulled")

# clean data -------------------------------------------------------------
setDT(dat_raw)
dat_raw <- dat_raw[!is.na(`Week of`)] #newest data has `Week of` column
cols <- sapply(dat_raw, function(x)!all(is.na(x)))
cols <- names(cols)[cols]
dat_raw <- dat_raw[,..cols]

dat_raw[, update_date := gsub(pattern = "([0-9]+).*$", "\\1",basename(date_pulled))]
dat_raw[, update_date := as.POSIXct(update_date, format = "%Y%m%d%H%M")]
dat_raw[, update_date:= as.Date(format(update_date,'%Y-%m-%d'))]

dat_raw <- dat_raw[!is.na(County) & Demographic!='Age Group K-12']

#updated verbiage
dat_raw$`People at Least Partially Vaccinated`[is.na(dat_raw$`People at Least Partially Vaccinated`)] <- 
  dat_raw$`People Vaccinated with at Least One Dose`[is.na(dat_raw$`People at Least Partially Vaccinated`)]

# long format
dat_raw_long <- melt(dat_raw, id.vars = c('update_date','Week of',
                                          'Aggregation Level',
                                          'County', 'County Population',
                                          'Demographic', 'County Demographic Population',
                                          'Fully Vax NC Population','One Dose NC Population',
                                          'Ethnicity', 'Race', 'Age Group', 'Gender'),
                     measure.vars = c('People at Least Partially Vaccinated',
                                      'People Fully Vaccinated'),
                     value.name = 'value')
dat_raw_long[,status:=ifelse(grepl('Partial',variable),'partial','full')]
dat_raw_long[,Demographic:=ifelse(Demographic=='Gender', 'Sex', Demographic)]
# get rid of unnecessary columns
dat_raw_long[,DemographicIdentity:=case_when(Demographic=='Race'~Race,
                                             Demographic=='Age Group'~`Age Group`,
                                             Demographic=='Ethnicity'~Ethnicity,
                                             Demographic=='Sex'~Gender,
                                             TRUE~'Unknown')]

## population estimates for full and partial may change if suppressed population is different? 
dat_raw_long[,`County Demographic Population` := case_when(!is.na(`County Demographic Population`)~`County Demographic Population`,
                                                          status=='partial'~`One Dose NC Population`,
                                                          TRUE~`Fully Vax NC Population`)]

cols <- c('update_date','Week of', 'Aggregation Level',
          'County','County Population',
          'Demographic','County Demographic Population',
          'DemographicIdentity',
          #'measure', 'dose',
          'status','variable', 'value')
dat_raw_long <- dat_raw_long[,..cols]
setnames(dat_raw_long, cols, c('date_pulled', 'week_of', 'aggregation_level',
                               'county', 'county_pop',
                               'demographic', 'county_demo_pop',
                               'demographic_identity',
                               #'measure', 'dose',
                               'status', 'variable', 'vax_n'))

dat_raw_final <- dat_raw_long[,list(county_demo_pop = sum(county_demo_pop, na.rm = T),
                                    vax_n = sum(vax_n, na.rm = T)),
                              by = setdiff(names(dat_raw_long), c('vax_n', 'county_demo_pop'))]
#0 population to NA
dat_raw_final[,county_demo_pop:=ifelse(county_demo_pop==0,as.numeric(NA),
                                       county_demo_pop)]

# save data ------------------------------------------------------------
#chunk <- 50000
#n <- nrow(dat_raw_final)
#r  <- rep(1:ceiling(n/chunk),each=chunk)[1:n]
#d <- split(dat_raw_final,r)

## Write as chunks
#
#for(i in 1:length(d)){
#  data.table::fwrite(d[[i]], here::here("data", "timeseries", sprintf("vax-demos-%s.csv", i)))
#}

#n_files <- length(d)

#cat(n_files, file = here::here("data","timeseries","vax-demos-length.txt"))

dat_raw_out = dat_raw_final[date_pulled==max(date_pulled)]

data.table::fwrite(dat_raw_out, here::here("data", "timeseries", "vax-demos.csv"))
