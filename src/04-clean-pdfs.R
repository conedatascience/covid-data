#
# in_files <- fs::dir_ls(file.path("data", "daily-race"), glob = "*.pdf")
#
# in_pdf <- lapply(in_files, pdftools::pdf_text)
#
# writeLines(in_pdf[[1]], "test.txt")
#
# trimws(strsplit(readLines("test.txt")[24])
