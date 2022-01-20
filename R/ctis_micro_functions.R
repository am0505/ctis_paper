ctis_micro_get_estimates_v1_urbancity <- function(.table_name) {
  
  file_date <- ymd(str_remove(.table_name, "full_"))
  
  message("Getting vaccination urbancity estimates for date: ", file_date)
  
  ctis_srvy <- con_ctis %>% 
    tbl(.table_name) %>%
    select(date, region_agg, weight, finished, e2, e3, e4, v1) %>%
    filter(v1 %in% c("1", "2") & e2 %in% c("1", "2", "3")) %>% 
    as_survey_design(1,
                     strata = region_agg,
                     weight = weight)
  
  suppressMessages(
    ctis_srvy_summary <- ctis_srvy %>%
      group_by(date, e2, v1) %>%
      summarize(proportion = survey_mean(deff = T),
                n = unweighted(n())) %>%
      ungroup() %>%
      mutate(unw_prop = n/sum(n),
             date = ymd(date))
  )
  
  return(ctis_srvy_summary)
  
}
