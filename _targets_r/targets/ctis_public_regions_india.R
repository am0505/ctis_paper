tar_target(
  ctis_public_regions_india,
  ctis_public_regions %>%
    filter(country == "India") %>%
    pull(region) %>%
    append(NA)
)
