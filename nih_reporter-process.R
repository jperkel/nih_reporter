library(tidyverse)
library(lubridate)

datafile <- 'tmp/nih_data-20250219.csv'
datafile2 <- 'tmp/nih_data-20250218.csv'

mydata <- read_csv(datafile) |> 
  janitor::clean_names()

mydata2 <- read_csv(datafile2) |> 
  janitor::clean_names()

# no data collected for 11 or 20 Jan 2025, so pull them in from earlier run
missingdata <- mydata2 |> 
  filter(award_date %in% c('2025-01-11', '2025-01-20')) 

# merge the datasets
fixed_data <- mydata |> 
  rbind(missingdata)

funding_per_wk <- fixed_data |> 
  mutate(
    week = lubridate::week(award_date),
    year = lubridate::year(award_date)
    ) |> 
  group_by(year, week, award_type) |> 
  summarize(count = n(),
            total = sum(award_amount)) 

write_csv(x = funding_per_wk, file = '~/Downloads/funding_per_wk-20250219.csv')
write_csv(x = fixed_data, file = '~/Downloads/fixed_data-20250219.csv')