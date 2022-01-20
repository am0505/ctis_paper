tar_target(
  ind_pop_adult_projections,
  read_excel(here("data/pop_projection_adult_oct2021.xlsx")) %>% 
    clean_names() %>% 
    select(state, person, male, female) %>% 
    mutate_if(is.double, as.integer) %>% 
    mutate(across(c("person", "male", "female"), ~ .x * 1000)) %>%
    mutate(state = case_when(state == "India" ~ "All Regions",
                             state == "Delhi" ~ "NCT of Delhi",
                             TRUE ~ state)),
  format = "fst_tbl"
)
