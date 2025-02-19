library(tidyverse)
library(lubridate)
library(scales)

datafile <- '~/Downloads/fixed_data-20250219.csv'

mydata <- read_csv(datafile) |> 
  janitor::clean_names()

p <- mydata |> 
  mutate(
    year = factor(lubridate::year(award_date), levels = 2021:2025),
    week = factor(lubridate::week(award_date), levels = c(44:53, 1:7))
  ) |> 
  group_by(year, week, award_type) |> 
  summarize(count = n(),
            total = sum(award_amount, na.rm = TRUE)) |> 
  ungroup() |> 
  # mutate(yr_wk = stringr::str_c(year, week, sep = '-')) |> 
  # filter(award_type %in% c('1', '2', '3', '4C', '4N')) |> 
  ggplot(aes(x = week, y = total / 1000, fill = year)) +
  geom_col(position = position_dodge(), color = 'black') +
  ylab("Total (Thousands of Dollars)") +
  scale_y_continuous(labels = label_comma()) +
  facet_grid('award_type') +
  theme(axis.text.x = element_text(angle = 45))
  
 ggsave(filename = '~/Documents/Nature/Programming/nih_reporter/weekly_data-20250219.jpg', 
       plot = p, 
       height = 11, 
       width = 8.5, 
       units = "in")