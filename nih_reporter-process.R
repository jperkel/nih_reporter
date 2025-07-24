library(tidyverse)

working_dir <- '~/Documents/Nature/Programming/nih_reporter'
# datafile <- file.path(working_dir, 'data/nih_data-20250219.csv')
# datafile2 <- file.path(working_dir, 'data/nih_data-20250218.csv')
datafile <- file.path(working_dir, 'data/nih_data-20250723.csv')

mydata <- read_csv(datafile) |> 
  janitor::clean_names()

# remove duplicate entries
mydata <- mydata |> distinct() 

# no data collected for 11 or 20 Jan 2025, so pull them in from earlier run (datafile2)
# mydata2 <- read_csv(datafile2) |> 
#   janitor::clean_names()

# missingdata <- mydata2 |> 
#   filter(award_date %in% c('2025-01-11', '2025-01-20')) 

# # check for duplicates
# dups <- mydata[which(duplicated(mydata$project_number)),]$project_number
# length(dups)
# # [1] 120

# dups2 <- mydata2[which(duplicated(mydata2$project_number)),]$project_number
# length(dups2)
# # [1] 0

# # alt approach, from https://www.statology.org/dplyr-find-duplicates/
# mydata |> 
#   group_by_all() |> 
#   filter(n() > 1) |> 
#   ungroup() |> 
#   arrange(project_number)
# # A tibble: 240 × 4
# # award_date project_number    award_amount award_type
# # <date>     <chr>                    <dbl> <chr>     
# # 1 2025-01-10 1I01BX006638-01A1            0 1         
# # 2 2025-01-10 1I01BX006638-01A1            0 1         
# # 3 2025-01-10 1I01RX005006-01              0 1         
# # 4 2025-01-10 1I01RX005006-01              0 1         
# # 5 2025-01-10 1IK2HX003783-01A2            0 1         
# # 6 2025-01-10 1IK2HX003783-01A2            0 1         
# # 7 2025-01-19 1K24AR085177-01         212574 1         
# # 8 2025-01-19 1K24AR085177-01         212574 1         
# # 9 2025-01-10 1K99EY036889-01         123794 1         
# # 10 2025-01-10 1K99EY036889-01         123794 1         
# # ℹ 230 more rows

# # 120 duplicated records in mydata; view them
# mydata |> 
#   filter(project_number %in% dups) |> 
#   View()  
# # sort by project number; if date & award amt are the same, they are duplicates

# # merge the datasets & remove duplicates
# fixed_data <- mydata |> 
#   rbind(missingdata) |> 
#   arrange(project_number) |> 
#   distinct()

# funding_per_wk <- fixed_data |> 
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
# write_csv(x = fixed_data, file = file.path(working_dir, glue::glue('outputs/fixed_data-{today}.csv')))

# fixed_data for 1 Jan - 16 Feb should total $1.62 bn:
# fixed_data |> 
#   filter(award_date >= '2025-01-01') |> 
#   pluck('award_amount') |> 
#   sum()
# # [1] 1620716873

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
