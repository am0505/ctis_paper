clean_state_names <- function(.df) {
  .df %>%
    mutate(state = case_when(state == "Total" ~ "All Regions",
                             state == "India" ~ "All Regions",
                             state == "Delhi" ~ "NCT of Delhi",
                             TRUE ~ state)) 
}


merge_vaccine_estimates <- function(c19_bharat_data, 
                                    ind_pop_adult_projections, 
                                    ctis_india_public) {
  
  ind_pop_18p <- ind_pop_adult_projections %>% 
    select(state, pop_person = person)
  
  ctis_vaccine <- ctis_india_public %>%
    filter(indicator %in% c("covid_vaccine", "twodoses")) %>% 
    select(date, state = region, indicator, wt_pct, wt_pct_se) %>% 
    mutate(indicator = case_when(indicator == "covid_vaccine" ~ "covid_vaccine_recieved",
                                 indicator == "twodoses" ~ "covid_vaccine_twodoses")) %>% 
    pivot_wider(names_from = indicator,
                values_from = c(wt_pct, wt_pct_se)) %>% 
    filter(!is.na(date))
  
  c19_vaccine_merged <- c19_bharat_data$c19bh_data_vaccine_st %>% 
    select(date, state, n1d = first_dose_administered, n2d = second_dose_administered, ntd = total_doses_administered) %>% 
    left_join(ind_pop_18p, 
              by = "state") %>% 
    mutate(x1d = n1d/pop_person,
           x2d = n2d/pop_person,
           xtd = ntd/pop_person) %>% 
    select(-pop_person) %>% 
    inner_join(ctis_vaccine, 
              by = c("state", "date")) %>% 
    filter(!(state == "All Regions" & date == "2021-05-15"))
  
  return(c19_vaccine_merged)
  
}

merge_covid_estimates <- function(c19_bharat_data,
                                  ind_pop_projections,
                                  ctis_india_public) {
  
  ind_pop_projections_df <- ind_pop_projections$pop %>% 
    select(state, pop_person)
  
  ctis_wt_pct <- ctis_india_public %>%
    select(date, state = region, indicator, wt_pct, wt_pct_se) %>% 
    pivot_wider(names_from = indicator,
                values_from = c(wt_pct, wt_pct_se)) %>% 
    filter(!is.na(date))
  
  c19_covid_merged <- c19_bharat_data$c19bh_data_st %>% 
    #select(date, state, confirmed, recovered, deceased, other, tested) %>% 
    left_join(ind_pop_projections_df,
              by = "state") %>%
    mutate(xconfirmed = confirmed/pop_person,
           xrecovered = recovered/pop_person,
           xother = deceased/pop_person,
           xother = other/pop_person,
           xtested = tested/pop_person) %>%
    select(-pop_person) %>%
    inner_join(ctis_wt_pct, 
              by = c("state", "date"))
  
  return(c19_covid_merged)
  
}
