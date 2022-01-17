################################################################################
#
# Project build script
#
################################################################################

# Load packages (in packages.R)
suppressPackageStartupMessages(source("packages.R"))

# Load project-specific functions in R folder
for (f in list.files(here::here("R"), full.names = TRUE)) source (f)

# Groups of targets ------------------------------------------------------------

## CTIS Public Targets
source(here("code/ctis_public_targets.R"))
## COVID India Targets
source(here("code/covid_india_targets.R"))
## India Population Targets
source(here("code/pop_ind_targets.R"))

## _targets.R needs to finish with a list()
list(
  ctis_public_targets,
  covid_india_targets,
  pop_ind_targets
)
