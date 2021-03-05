# Consolidate Vaccination Demographic Records for North Carolina
library(dplyr)
library(data.table)

# raw data location ------------------------------------------------------

data_dir <- fs::dir_ls(here::here("data", "vax-demos"), glob = "*csv")


# import data -------------------------------------------------------------

dat_raw <- purrr::map_dfr(data_dir, data.table::fread, .id = "date_pulled")

# clean data -------------------------------------------------------------
setDT(dat_raw)
dat_raw[, update_date := gsub(pattern = "([0-9]+).*$", "\\1",basename(date_pulled))]
dat_raw[, update_date := as.POSIXct(update_date, format = "%Y%m%d%H%M")]
dat_raw[, date:= as.Date(format(update_date,'%Y-%m-%d'))]

# git rid of old columns that were covid-19 cases instead of vaccinations
cols <- names(dat_raw)[!grepl('Confirmed|Suspected', names(dat_raw))]
dat_raw <- dat_raw[!is.na(County) & Demographic!='Age Group K-12',..cols]

# long format
dat_raw_long <- melt(dat_raw, id.vars = c('date_pulled', 'update_date', 'date',
                                          'County', 'Demographic', 'Ethnicity',
                                     'Aggregation Level', 'Race', 'Age Group', 'Gender'),
                     measure.vars = c('First Doses ~ Percent of Total',
                                   'First Doses ~ Percent of Population Vaccinated',
                                   'Second Doses ~ Percent of Total',
                                   'Second Doses ~ Percent of Population Vaccinated'),
                 value.name = 'value')
dat_raw_long[,dose:=ifelse(grepl('First',variable),1,2)]
dat_raw_long[,measure:=ifelse(grepl('Population',variable),'PerCapita','Distribution')]
dat_raw_long[,Demographic:=ifelse(Demographic=='Gender', 'Sex', Demographic)]
# get rid of unnecessary columns
dat_raw_long[,DemographicIdentity:=case_when(Demographic=='Race'~Race,
                                             Demographic=='Age Group'~`Age Group`,
                                             Demographic=='Ethnicity'~Ethnicity,
                                             Demographic=='Sex'~Gender,
                                             TRUE~'Unknown')]
cols <- c('date','Aggregation Level',
          'County','Demographic', 'DemographicIdentity',
          'measure', 'dose', 'variable', 'value')
dat_raw_long <- dat_raw_long[,..cols]
setnames(dat_raw_long, cols, c('date','aggregation_level',
                               'county', 'demographic', 'demographic_identity',
                               'measure', 'dose', 'variable', 'value'))

# aggregate the missing/undisclosed values for vaccine distribution
#     remove for per capita rates - don't know the population it's referencing
dat_raw_final <- dat_raw_long[!(demographic_identity=='Missing or Undisclosed' &
                                  measure=='PerCapita'),
                              list(value = sum(value, na.rm = T)),
                              by = setdiff(names(dat_raw_long), 'value')]

# get baseline numbers ---------------------------------------------------------
# need population data & total vaccine numbers to convert rates to numbers

# vaccine totals
vax_totals <- data.table::fread(here::here("data", "timeseries", "nc-vaccinations.csv"))
setDT(vax_totals)
vax_totals <- vax_totals[,.(date,county,dose_1,dose_2)]
vax_totals[,aggregation_level:='County']
vax_nc <- vax_totals[,list(dose_1 = sum(dose_1, na.rm = T),
                           dose_2 = sum(dose_2, na.rm = T),
                           county = 'North Carolina',
                           aggregation_level = 'Statewide'),
                     by = .(date)]
vax_totals <- rbind(vax_totals, vax_nc)

# population totals
pop_totals <- data.table::fread(here::here("data", "county-detail", "nc-pop-demo.csv"))


# merge to demo vax
dat_with_vax <- merge.data.frame(dat_raw_final, vax_totals,
                                 by = c('date','aggregation_level','county'),
                                 all.x = T)

dat_with_vax_pop <- merge(dat_with_vax,
                      pop_totals %>% filter(demographic!='Age Group K-12'),
                      by = c('aggregation_level','county',
                             'demographic', 'demographic_identity'),
                      all.x = T)
setDT(dat_with_vax_pop)
dat_with_vax_pop[,n:=case_when(measure=='Distribution'&dose==1~value*dose_1,
                               measure=='Distribution'&dose==2~value*dose_2,
                               measure=='PerCapita'~value*population,
                               TRUE~as.numeric(NA)
                            )]
setnames(dat_with_vax_pop, c('dose_1', 'dose_2', 'population', 'value','n'),
         c('demo_total_dose_1','demo_total_dose_2','demo_population',
           'vax_prop','vax_n'))

dat_with_vax_pop <- dat_with_vax_pop[,.(date, aggregation_level, county, demographic,
                                        demographic_identity, measure, dose, variable, vax_prop, vax_n,
                                        demo_population, demo_total_dose_1, demo_total_dose_2)]

# save data ------------------------------------------------------------
data.table::fwrite(dat_with_vax_pop, here::here("data", "timeseries", "vax-demos.csv"))
