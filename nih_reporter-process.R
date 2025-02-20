library(tidyverse)
library(lubridate)

datafile <- 'tmp/nih_data-20250219.csv'
datafile2 <- 'tmp/nih_data-20250218.csv'

mydata <- read_csv(datafile) |> 
  janitor::clean_names()

# no data collected for 11 or 20 Jan 2025, so pull them in from earlier run (datafile2)
mydata2 <- read_csv(datafile2) |> 
  janitor::clean_names()

missingdata <- mydata2 |> 
  filter(award_date %in% c('2025-01-11', '2025-01-20')) 

# merge the datasets
fixed_data <- mydata |> 
  rbind(missingdata) |> 
  # remove duplicates
  arrange(project_number) |> 
  distinct()

funding_per_wk <- fixed_data |> 
  mutate(
    week = lubridate::week(award_date),
    year = lubridate::year(award_date)
    ) |> 
  group_by(year, week, award_type) |> 
  summarize(count = n(),
            total = sum(award_amount)) 

write_csv(x = funding_per_wk, file = 'tmp/funding_per_wk-20250219.csv')
write_csv(x = fixed_data, file = 'tmp/fixed_data-20250219.csv')

# fixed_data for 1 Jan - 16 Feb should total $1.62 bn:
fixed_data |> 
  filter(award_date >= '2025-01-01') |> 
  pluck('award_amount') |> 
  sum()

# [1] 1620716873

# make sure no data lost -- eg, if there are >500 records for a given day:
fixed_data |> 
  group_by(award_date) |> 
  summarize(count = n()) |> 
  arrange(desc(count))

# # A tibble: 412 × 2
# award_date count
# <date>     <int>
# 1 2023-01-31   352
# 2 2022-01-31   320
# 3 2023-02-01   311
# 4 2023-01-20   297
# 5 2024-12-20   297
# 6 2023-01-30   295
# 7 2023-01-27   284
# 8 2022-02-01   280
# 9 2023-01-25   276
# 10 2025-01-27   268
# # ℹ 402 more rows
# # ℹ Use `print(n = ...)` to see more rows
