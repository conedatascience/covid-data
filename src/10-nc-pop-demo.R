# Population Totals used by NCDHHS Dashboard
# county & statewide totals

library(dplyr)
library(data.table)

# read in data -------------------------------------------------------------
pop_totals <- data.table::fread(here::here('data', 'timeseries', 'state-facts.csv'))

# select demographic columns -----------------------------------------------
pop_totals <- pop_totals %>% filter(County!='Missing') %>%
  select(County, starts_with('age'), ends_with('pop')) %>%
  select(-ends_with("-1"), -ends_with("-2")) %>%
  melt(id = c('County'), value.name = 'population')

# clean up columns ---------------------------------------------------------
pop_totals[,aggregation_level:='County']
pop_totals[,variable:=gsub('_pop','',variable, fixed = T)]
pop_totals[,demographic:=case_when(variable %in% paste0('age_',c('0_1',
                                                                 '2_4',
                                                                 '5_9',
                                                                 '10_14',
                                                                 '15_17'))~ 'Age Group K-12',
                                   grepl('^age',variable)~'Age Group',
                                   grepl('hisp', variable)~'Ethnicity',
                                   variable %in% c('male', 'female')~'Sex',
                                   TRUE~'Race')]
pop_totals[,demographic_identity:=case_when(grepl('^age',variable)~gsub('_','-',
                                                                        gsub('_up','+',
                                                                             gsub('age_','',variable))),
                                            variable%in%c('white','male','female',
                                                          'hispanic')~stringr::str_to_title(variable),
                                            variable=='ai_an'~'American Indian or Alaskan Native',
                                            variable=='asian_pi'~'Asian or Pacific Islander',
                                            variable=='black'~'Black or African American',
                                            variable=='nonhisp'~'Non-Hispanic',
                                            TRUE~'Unknown')]
pop_totals <- pop_totals[,.(County,demographic,demographic_identity,population,
                            aggregation_level)]
setnames(pop_totals,'County','county')

# nc & county level population totals -------------------------------------------
nc_pop <- pop_totals[,list(population = sum(population, na.rm = T),
                           county = 'North Carolina',
                           aggregation_level = 'Statewide'),
                     by = .(demographic, demographic_identity)]
pop_totals <- rbind(pop_totals, nc_pop)

# write output -----------------------------------------------------------------
data.table::fwrite(pop_totals,
                   here::here("data", "county-detail", "nc-pop-demo.csv"))
