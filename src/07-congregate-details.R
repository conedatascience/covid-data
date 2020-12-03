library(data.table)
library(dplyr)
library(pdftools)
cat("Starting Outbreak Pdf Scrapes\n\n")
# bring in files and select oldest by date --------------------------------
in_files <- fs::dir_info(file.path("data", "daily-outbreaks", "report"), glob = "*.pdf")


in_files$update_date <- gsub(pattern = "([0-9]+).*$", "\\1",basename(in_files$path))

in_files$update_date <- as.POSIXct(in_files$update_date, format = "%Y%m%d%H%M")

in_files$update_date_only <- lubridate::date(in_files$update_date)

in_files <- in_files %>%
  dplyr::group_by(update_date_only) %>%
  dplyr::filter(update_date==max(update_date)) %>%
  slice(1) %>%
  ungroup()

in_pdf <- lapply(in_files%>%
                   dplyr::pull(path), pdftools::pdf_text)

in_pdf <- lapply(in_pdf, function(x) {x <- x[-1]})

names(in_pdf) <- in_files %>% pull(update_date_only)

cat(names(in_pdf))
x <- in_pdf[[81]]

xfun::write_utf8(in_pdf[[81]], "test.txt")

process_outbreaks <- function(x){

  x <- gsub("\uab37", '', x)
  x <- gsub("≠", '', x)
  x <- gsub("•", '', x)

  x2 <- iconv(x, from = "utf-8", to = "ascii")
  xfun::write_utf8(x2, "test.txt")

  path <- file.path("src", "07-congregate-details.sh")
  call <- sprintf("bash %s", path)

  cat("processing...\n")
  system(call)

  unlink("test.txt")

  formated_text <- data.table::fread("test3.txt")

  if(ncol(formated_text)==9){
    names(formated_text) <- c("facility_type", "facility_county", "facility_name",
                              "staff_cases",
                              "staff_deaths", "resident_cases", "resident_deaths",
                              "total_cases", "total_deaths")

    formated_text
  } else {NULL}



}

combined_data <- list()

for(i in 1:length(in_pdf)){
  cat("processing: ", i," out of ",length(in_pdf) , "\n")
  combined_data[[i]] <- process_outbreaks(in_pdf[[i]])
}
process_outbreaks(in_pdf[[81]])
#combined_data <- try(purrr::map_dfr(in_pdf, process_pdfs, .id = "date"))

names(combined_data) <- in_files %>% pull(update_date_only)

combined_data <- rbindlist(combined_data, idcol = TRUE)

combined_data <- combined_data[ , daily_cases:=total_cases - data.table::shift(total_cases, type = "lag"), by = facility_name]
combined_data <- combined_data[ , daily_deaths:=total_deaths - data.table::shift(total_deaths, type = "lag"), by = facility_name]

cat(nrow(combined_data))
# write outputs -----------------------------------------------------------

if(!"try-error"%in%class(combined_data)){
  data.table::fwrite(combined_data, here::here("data", "timeseries", "nc-congregate-outbreaks.csv"))

}
