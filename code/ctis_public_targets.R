ctis_public_targets <- list(
  ## CTIS Public API Targets
  tar_target(
    ctis_public_doc,
    ctis_get_public_apidoc(),
    format = "fst_tbl"
  ),
  tar_target(
    ctis_public_indicators,
    ctis_public_doc %>%
      filter(indicator %in% c("covid", "flu", "anosmia", "vaccine_acpt", "covid_vaccine", "twodoses")) %>%
      pull(indicator)
  ),
  ### CTIS Country Regions
  tar_target(
    ctis_public_regions,
    ctis_get_public_regions(),
    format = "fst_tbl"
  ),
  tar_target(
    ctis_public_regions_india,
    ctis_public_regions %>%
      filter(country == "India") %>%
      pull(region) %>%
      append(NA)
  ),
  tar_target(
    ctis_india_public,
    ctis_get_public_data(indicator = ctis_public_indicators, 
                         region = ctis_public_regions_india, 
                         date_end = as.character(Sys.Date() - 3)),
    pattern = cross(ctis_public_indicators, ctis_public_regions_india),
    format = "fst_tbl",
    #iteration = "list",
    cue = tarchetypes::tar_cue_age(
      name = ctis_india_public,
      age = as.difftime(1, units = "days")
    )
  )
)
