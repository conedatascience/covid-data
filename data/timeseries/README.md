# Data Dictionary

This directory holds all of the timeseries data for the state metrics. 
Each day, information is tacked onto these files to represent a running total for all of these measures.

## nc-cases-by-county.csv

Contains the cases and deaths by county by day. Additionally, there are geospatial fields and the total hospitalizations repeated on each row for the state.

## nc-cases-by-zip.csv

Contains the cases and deaths by zip code by day. Additionally, there are geospatial fields and the total hospitalizations repeated on each row for the state.

## nc-demographics.csv

Contains the aggregate statistics for demographics by day. Eventually, I will add a column for the daily changes, but currently everything is cumulative.

## To Do

Currently, several pieces of data are being collected, but I still need to write some cleaning scripts:

- [ ] Daily number hospitalized  
- [ ] Daily number of beds available 
- [ ] State summary metrics for testing and the specimen collection date at the state level  
