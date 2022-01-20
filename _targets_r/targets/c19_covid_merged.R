tar_target(
  c19_covid_merged,
  merge_covid_estimates(c19_bharat_data,
                        ind_pop_projections,
                        ctis_india_public),
  format = "fst_tbl"
)

