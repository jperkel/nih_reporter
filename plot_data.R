library(tidyverse)

working_dir <- '~/Documents/Nature/Programming/nih_reporter'
# datafile <- file.path(working_dir, 'data/nih_data-20250219.csv')
# use pre-processed data instead!
datafile <- file.path(working_dir, 'data/funding_per_wk-20250219.csv')

mydata <- read_csv(datafile)

# old graph, using raw NIH data instead of 'funding_per_wk' table
# this graph plots the data by individual week, rather than binning into 3-week chunks
#
# p <- mydata |>
#   mutate(
#     year = factor(lubridate::year(award_date), levels = 2021:2025),
#     week = factor(lubridate::week(award_date), levels = c(44:53, 1:7))
#   ) |>
#   filter(week %in% 1:7) |> 
#   group_by(year, week, award_type) |>
#   summarize(count = n(),
#             total = sum(award_amount, na.rm = TRUE)) |>
#   ungroup() |>
#   # mutate(yr_wk = stringr::str_c(year, week, sep = '-')) |>
#   # filter(award_type %in% c('1', '2', '3', '4C', '4N')) |>
#   ggplot(aes(x = week, y = total / 1000, fill = year)) +
#   geom_col(position = position_dodge(), color = 'black') +
#   ylab("Total (Thousands of Dollars)") +
#   scale_y_continuous(labels = label_comma()) +
#   facet_grid('award_type') +
#   theme(axis.text.x = element_text(angle = 45))
#   
#  ggsave(filename = '~/Documents/Nature/Programming/nih_reporter/weekly_data-20250219.jpg', 
#        plot = p, 
#        height = 11, 
#        width = 8.5, 
#        units = "in")
 
 
 ## to reproduce the figs in the published article:
mydata <-  mydata |>  
  mutate(mygroup = case_when(week %in% 1:3 ~ "Weeks 1-3",
                             week %in% 4:6 ~ "Weeks 4-6",
                             .default = "Other")) |> 
  mutate(award_class = case_when(award_type == '1' ~ 'New grants',
                                 .default = 'Other')) |> 
  mutate(award_class = factor(award_class, levels = c("Other", "New grants"))) |> 
  filter(mygroup != "Other") |> 
  group_by(year, mygroup, award_class) |> 
  summarize(count = sum(count),
            total = sum(total, na.rm = TRUE)) |> 
  ungroup() 

# total funding
mydata |>  
   ggplot(aes(x = mygroup, y = total / 1000000, fill = award_class)) +
   geom_col(position = position_stack(), color = 'black') +
   ylab("Total (millions)") +
   scale_y_continuous(labels = scales::label_comma()) +
   facet_wrap('year') +
   theme(legend.position = "top") +
   xlab(NULL)
 
# number of grants
 mydata |>  
   ggplot(aes(x = mygroup, y = count / 1000, fill = award_class)) +
   geom_col(position = position_stack(), color = 'black') +
   ylab("No. Grants (thousands)") +
   facet_wrap('year') +
   theme(legend.position = "top") +
   xlab(NULL)