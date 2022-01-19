# Consolidate Vaccination Demographic Records for North Carolina
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

dat_raw$update_date <- as.Date(file.info(file_loc)$mtime)

#updated verbiage
dat_raw <- dat_raw %>% rename(`People at Least Partially Vaccinated`=`People Vaccinated with at Least One Dose`)

#dat_raw$`People Vaccinated with at Least One Dose` = dat_raw$`People at Least Partially Vaccinated`

# Fixing Some Additional Naming Irregularities

setnames(dat_raw, "Two Doses or One Dose JJ Population", 'Fully Vaccinated Population')

setnames(dat_raw, "People Vaccinated with Two Doses or One Dose JJ", 'People Fully Vaccinated')

setnames(dat_raw, "Percent of Population Vaccinated with Two Doses or One Dose JJ", 'Percent of Population Fully Vaccinated')

setnames(dat_raw, )

# long format
dat_raw_long <- melt(dat_raw, id.vars = c('update_date','Week of',
                                          'Aggregation Level',
                                          'County', 
                                          'Demographic',
                                          'Fully Vaccinated Population','One Dose Population',
                                          'Ethnicity', 'Race', 'Age Group', 'Gender',
                                          'Percent of Population Fully Vaccinated',
                                          'Percent of Population Vaccinated with at Least One Dose'
                                          ),
                     measure.vars = c('People at Least Partially Vaccinated',
                                      'People Fully Vaccinated'
                                      ),
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
dat_raw_long[,`County Demographic Population` := case_when(status=='partial'~`One Dose Population`,
                                                          TRUE~`Fully Vaccinated Population`)]

cols <- c('update_date','Week of', 'Aggregation Level',
          'County',
          'Demographic','County Demographic Population',
          'DemographicIdentity',
          'status','variable', 'value')
dat_raw_long <- dat_raw_long[,..cols]
setnames(dat_raw_long, cols, c('date_pulled', 'week_of', 'aggregation_level',
                               'county', 
                               'demographic', 'county_demo_pop',
                               'demographic_identity',
                               'status', 'variable', 'vax_n'))

dat_raw_final <- dat_raw_long[,list(county_demo_pop = sum(county_demo_pop, na.rm = T),
                                    vax_n = sum(vax_n, na.rm = T)),
                              by = setdiff(names(dat_raw_long), c('vax_n', 'county_demo_pop'))]
#0 population to NA
dat_raw_final[,county_demo_pop:=ifelse(county_demo_pop==0,as.numeric(NA),
                                       county_demo_pop)]


dat_raw_out = dat_raw_final[date_pulled==max(date_pulled)]

data.table::fwrite(dat_raw_out, here::here("data", "timeseries", "vax-demos.csv"))
