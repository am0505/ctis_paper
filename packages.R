######################## LOAD R PACKAGES #######################################

################################################################################
#
#' R packages needed to run any/most {targets} workflows
#
################################################################################

## library() calls go here
library(conflicted)
library(dotenv)
library(targets)
library(tarchetypes)
library(tflow)
library(fnmate)

library(here)
library(knitr)
library(rmarkdown)


################################################################################
#
#' Additional R packages needed to run your specific workflow
#' 
#' * Delete or hash out lines of code for R packages not needed in your workflow
#' * Insert code here to load additional R packages that your workflow requires
#
################################################################################

## renv::install("an0505/ctisglobal")
library(ctisglobal)

library(tidyverse)
library(vroom)
library(janitor)
library(lubridate)
library(readxl)

conflict_prefer("filter", "dplyr")
conflict_prefer("lag", "dplyr")
