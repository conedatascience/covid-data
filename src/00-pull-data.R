# now get county data -----------------------------------------------------
# Go to Arc-GIS Server for Public Map
# Using <https://stackoverflow.com/questions/50161492/how-do-i-scrape-data-from-an-arcgis-online-map>
current_time <- format(Sys.time(), "%Y%m%d%H%M")
out <- jsonlite::fromJSON(readLines("https://services.arcgis.com/iFBq2AW9XO0jYYF7/arcgis/rest/services/NCCovid19/FeatureServer/0/query?where=0%3D0&outFields=%2A&f=json"))

attribute_out <- out$features$attributes

data.table::fwrite(attribute_out, here::here("data", "daily", paste0(current_time,"_ncdhss.csv")))
#readr::read_csv(here::here("tracker", "ncdhhs", paste0(current_time,"_ncdhss.csv")))
