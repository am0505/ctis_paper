covid_india_targets <- list(
  ## COVID-19 Bharat
  tar_target(
    c19_bharat_data,
    get_covid_bharat_data(),
    cue = tarchetypes::tar_cue_age(
      name = c19_bharat_data,
      age = as.difftime(1, units = "days")
    )
  )
)











