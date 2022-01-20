
library(conflicted)
library(dotenv)

library(targets)
library(tarchetypes)
library(here)
library(purrr, quietly = TRUE)

## renv::install("an0505/ctisglobal")
library(ctisglobal)

library(tidyverse)
library(vroom)
library(janitor)
library(lubridate)
library(readxl)

library(here)

conflict_prefer("filter", "dplyr")
conflict_prefer("lag", "dplyr")


functions <- list.files(here("R"), full.names = TRUE)
walk(functions, source)
