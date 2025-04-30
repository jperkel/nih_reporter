library(tidyverse)

# myurl <- 'https://reporter.nih.gov/project-details/10255113'
# myhtml <- read_html(myurl)
# 
# myurl <- 'https://reporter.nih.gov/services/Projects/ProjectInfo?projectId=10255113'
# r <- GET(myurl)
# 
# dat <- jsonlite::fromJSON(content(r, as = 'text')) 

datafile <- 'data/nih_data-20250429.csv'
mytable <- read_csv(datafile)

mytable <- mytable |> 
  mutate(project_url = str_replace(string = project_url, 
    pattern = "project-details/", 
    replacement = "services/Projects/Publications?projectId="))

myurls <- mytable |> purrr::pluck('project_url')
pmids <- NULL 

for (url in myurls) {
  # add a delay b/w calls
  Sys.sleep(2)
  r <- httr::GET(url)
  dat <- jsonlite::fromJSON(httr::content(r, as = 'text')) 
  
  # get a list of PubMed IDs assoc'd w/ a given grant (in this case, 10255113):
  pmids <- c(pmids, dat$results$pm_id)
}
pmids <- unique(pmids)
# myurl <- 'https://reporter.nih.gov/services/Projects/Publications?projectId=10307582'
