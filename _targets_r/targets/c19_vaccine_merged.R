tar_target(
  c19_vaccine_merged,
  merge_vaccine_estimates(c19_bharat_data, 
                          ind_pop_adult_projections,
                          ctis_india_public),
  format = "fst_tbl"
)

