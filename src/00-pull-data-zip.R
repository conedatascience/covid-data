# Map Credit: NCDHHS
# * ZIP code level data may change once residence is verified. The total number reflected in the ZIP code level data may differ from the total number of cases and deaths at either the county or state level.
# * Cases are suppressed in ZIP codes where the population is less than five hundred and there are less than five cases.
# All data are preliminary and may change as cases are investigated.

if(!require("dplyr", character.only = T)) install.packages("dplyr")
# Scrape and Save North Carolina Covid Cases
# target_url <- "https://www.ncdhhs.gov/covid-19-case-count-nc"
current_time <- format(Sys.time(), "%Y%m%d%H%M")

# now get zip data -----------------------------------------------------
# Public esri db is here:: https://www.arcgis.com/home/webmap/viewer.html?url=https://services.arcgis.com/iFBq2AW9XO0jYYF7/ArcGIS/rest/services/Covid19byZIPnew/FeatureServer/0&source=sd

#out <- try(jsonlite::fromJSON(readLines("https://services.arcgis.com/iFBq2AW9XO0jYYF7/arcgis/rest/services/Covid19byZIPnew/FeatureServer/0/query?where=0%3D0&outFields=%2A&f=json")))

#if(!"try-error" %in% class(out)){
#  attribute_out <- out$features$attributes
#  
#  attribute_out <- attribute_out %>%
#  mutate(DataGatherTS = current_time)
#  
#  data.table::fwrite(attribute_out, here::here("data","dailyzip",  paste0(current_time,"_ncdhss_byZIP.csv")))

#}


