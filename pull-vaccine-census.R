# Purpose: Scrap Vaccine Data By Census from NCDHHS Esri Site 
current_time <- format(Sys.time(), "%Y%m%d%H%M")

# All NC County FIPS
# In order not to violate max query county, query by county
county_fips <- c("001", "003", "005", "007", "009", "011", "013", "015", "017", 
                 "019", "021", "023", "025", "027", "029", "031", "033", "035", 
                 "037", "039", "041", "043", "045", "047", "049", "051", "053", 
                 "055", "057", "059", "061", "063", "065", "067", "069", "071", 
                 "073", "075", "077", "079", "081", "083", "085", "087", "089", 
                 "091", "093", "095", "097", "099", "101", "103", "105", "107", 
                 "109", "111", "113", "115", "117", "119", "121", "123", "125", 
                 "127", "129", "131", "133", "135", "137", "139", "141", "143", 
                 "145", "147", "149", "151", "153", "155", "157", "159", "161", 
                 "163", "165", "167", "169", "171", "173", "175", "177", "179", 
                 "181", "183", "185", "187", "189", "191", "193", "195", "197", 
                 "199")

# Establish Collector for Outputs
collect_vaccines <- list()

for(i in county_fips){
  target2 <- glue::glue("https://services.arcgis.com/iFBq2AW9XO0jYYF7/arcgis/rest/services/NCVaccinesByTract/FeatureServer/0/query?where=COUNTYFP10={i}&outFields=%2A&f=json")
  out <- jsonlite::fromJSON(readLines(target2))
  collect_vaccines[[i]] <- out$features$attributes
  Sys.sleep(rpois(1,3)) 
}

# Convert Lists to 

collected_vaccines <- data.table::rbindlist(collect_vaccines)

collected_vaccines[,UpdateDTS:=current_time]

# Save Results to Disk

data.table::fwrite(collected_vaccines, here::here("data","daily-vax-census",  paste0(current_time,"_vax_by_census.csv")))