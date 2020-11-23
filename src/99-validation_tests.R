input_dat <- data.table::fread(here::here("data", "timeseries","nc-cases-by-county.csv"),
                               colClasses = c("character", "character", "Date", "integer", "integer", "double","integer","integer"))

library(validate)

# Check for the sanity of the values:
cf <- check_that(input_dat,
           cases_daily >= 0,
           deaths_daily >= 0,
           cases_confirmed_cum >=0,
           deaths_confirmed_cum >=0,
           !is.na(cases_daily),
           !is.na(deaths_daily)
)

# Summarise Results
validation_summary <- summary(cf)


validation <- sprintf("Confrontation: %s, Failures: %s, Time %s",
                      1:6, validation_summary$fails, format(Sys.time(),"%Y%m%d%H%M"))

cat(validation, file = here::here("log", "validation.txt"), append = T, sep = "\n")

# cmd_cd <- glue::glue("git add .")
#
# system(cmd_cd)
#
# cmd_cd <- glue::glue("git commit -m 'auto-update'")
#
# system(cmd_cd)
#
# system("git push origin master")
