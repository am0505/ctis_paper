tar_target(
  ctis_india_public,
  ctis_get_public_data(indicator = ctis_public_indicators, 
                       region = ctis_public_regions_india, 
                       date_end = as.character(Sys.Date() - 3)),
  pattern = cross(ctis_public_indicators, ctis_public_regions_india),
  format = "fst_tbl",
  cue = tarchetypes::tar_cue_age(
    name = ctis_india_public,
    age = as.difftime(1, units = "days")
  )
)

