county_names <- toupper(c("Alamance", "Alexander", "Alleghany", "Anson", "Ashe", "Avery", 
                 "Beaufort", "Bertie", "Bladen", "Brunswick", "Buncombe", "Burke", 
                 "Cabarrus", "Caldwell", "Camden", "Carteret", "Caswell", "Catawba", 
                 "Chatham", "Cherokee", "Chowan", "Clay", "Cleveland", "Columbus", 
                 "Craven", "Cumberland", "Currituck", "Dare", "Davidson", "Davie", 
                 "Duplin", "Durham", "Edgecombe", "Forsyth", "Franklin", "Gaston", 
                 "Gates", "Graham", "Granville", "Greene", "Guilford", "Halifax", 
                 "Harnett", "Haywood", "Henderson", "Hertford", "Hoke", "Hyde", 
                 "Iredell", "Jackson", "Johnston", "Jones", "Lee", "Lenoir", "Lincoln", 
                 "McDowell", "Macon", "Madison", "Martin", "Mecklenburg", "Mitchell", 
                 "Montgomery", "Moore", "Nash", "New Hanover", "Northampton", 
                 "Onslow", "Orange", "Pamlico", "Pasquotank", "Pender", "Perquimans", 
                 "Person", "Pitt", "Polk", "Randolph", "Richmond", "Robeson", 
                 "Rockingham", "Rowan", "Rutherford", "Sampson", "Scotland", "Stanly", 
                 "Stokes", "Surry", "Swain", "Transylvania", "Tyrrell", "Union", 
                 "Vance", "Wake", "Warren", "Washington", "Watauga", "Wayne", 
                 "Wilkes", "Wilson", "Yadkin", "Yancey"))
collect_svi <- list()

for(i in county_names){
  target <- glue::glue("https://services.arcgis.com/iFBq2AW9XO0jYYF7/arcgis/rest/services/CDC_SVI_2018/FeatureServer/0/query?where=COUNTY='{i}'&outFields=%2A&f=json")
  
   target <- gsub(" ", "%20", target)
  
  cat(paste0(i, "\n\n"))

  out <- jsonlite::fromJSON(readLines(target))
  collected_feature <- out$features$attributes
 
  
  collect_svi[[i]] <-collected_feature
  Sys.sleep(rpois(1,3))
  
}

collected_svi <- data.table::rbindlist(collect_svi)

data.table::fwrite(collected_svi, here::here("data","timeseries",  "svi-tract.csv"))