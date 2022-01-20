tar_target(
  ctis_public_indicators,
  ctis_public_doc %>%
    filter(indicator %in% c("covid", "flu", "anosmia", "vaccine_acpt", "covid_vaccine", "twodoses")) %>%
    pull(indicator)
)

