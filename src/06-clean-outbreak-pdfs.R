# library(data.table)
# library(dplyr)
# library(pdftools)
# cat("Starting Pdf Scrapes\n\n")
# # bring in files and select oldest by date --------------------------------
# in_files <- fs::dir_info(file.path("data", "daily-outbreaks"), glob = "*.pdf")
#
#
# in_files$update_date <- gsub(pattern = "([0-9]+).*$", "\\1",basename(in_files$path))
#
# in_files$update_date <- as.POSIXct(in_files$update_date, format = "%Y%m%d%H%M")
#
# in_files$update_date_only <- lubridate::date(in_files$update_date)
#
# in_files <- in_files %>%
#   dplyr::group_by(update_date_only) %>%
#   dplyr::filter(update_date==max(update_date)) %>%
#   slice(1) %>%
#   ungroup()
#
#
# in_pdf <- lapply(in_files%>%
#                    dplyr::pull(path), pdftools::pdf_text)
#
# names(in_pdf) <- in_files %>% pull(update_date_only)
#
# out <- stringr::str_extract_all(in_pdf[1], "\\d.+")
# out <- stringr::str_replace(out[[1]], pattern = "\\s+", replacement = ";")
# out <- strsplit(out, split = ";")
# txt <- do.call(rbind,out)
