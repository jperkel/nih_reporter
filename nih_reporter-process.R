library(tidyverse)

working_dir <- '~/Documents/Nature/Programming/nih_reporter'
# datafile <- file.path(working_dir, 'data/nih_data-20250219.csv')
# datafile2 <- file.path(working_dir, 'data/nih_data-20250218.csv')
datafile <- file.path(working_dir, 'data/nih_data-20250723.csv')

mydata <- read_csv(datafile) |> 
  janitor::clean_names()

# remove duplicate entries
mydata <- mydata |> distinct() 

funding_per_wk <- mydata |> 
  mutate(
    week = as.integer(lubridate::week(award_date)),
    year = as.integer(lubridate::year(award_date))
    ) |> 
  group_by(year, week, award_type) |> 
  summarize(count = n(),
            total = sum(award_amount)) 

today <- format(Sys.Date(), "%Y%m%d")
write_csv(x = funding_per_wk, file = file.path(working_dir, glue::glue('outputs/funding_per_wk-{today}.csv')))

# # make sure no data lost -- eg, if there are >500 records for a given day:
# fixed_data |> 
#   group_by(award_date) |> 
#   summarize(count = n()) |> 
#   arrange(desc(count))
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
