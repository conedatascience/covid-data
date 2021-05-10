
current_time <- format(Sys.time(), "%Y%m%d%H%M")

county_names <- c("Alamance", "Alexander", "Alleghany", "Anson", "Ashe", "Avery", 
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
                 "Wilkes", "Wilson", "Yadkin", "Yancey")
collect_vaccines <- list()

for(i in county_names){
  target <- glue::glue("https://services.arcgis.com/iFBq2AW9XO0jYYF7/arcgis/rest/services/VaxProviders/FeatureServer/0/query?where=VaccineAdministrationCounty='{i}'&outFields=%2A&f=json")
  
  target <- gsub(" ", "%20", target)
  
  cat(paste0(i, "\n\n"))
  out <- jsonlite::fromJSON(readLines(target))

if(!is.null(out$features$attributes)){
  collected_feature <- out$features$attributes
  collected_location <- out$features$geometry
  
  any_missing <- which(is.na(collected_location[,1]))

collected_feature <- collected_feature[-any_missing,]
collected_location <- collected_location[-any_missing,]
  # Need to Reproject to align with other stuff we do
  collected_location <- dplyr::mutate_all(collected_location,
                                   as.numeric) 
    
  collected_location <- sf::st_as_sf(x = collected_location,                         
             coords = c("x", "y"),
             crs = 2264)

  collected_location <- sf::st_transform(collected_location, 4326)
  
  collected_location <- as.data.frame(sf::st_coordinates(collected_location))
  
  
  collect_vaccines[[i]] <- cbind(collected_feature, collected_location) 
  Sys.sleep(rpois(1,3))
}
}


collected_vaccines <- data.table::rbindlist(collect_vaccines)

collected_vaccines[,UpdateDTS:=current_time]

# Save Results to Disk

data.table::fwrite(collected_vaccines, here::here("data","daily-vax-providers",  paste0(current_time,"_vax_provider.csv")))