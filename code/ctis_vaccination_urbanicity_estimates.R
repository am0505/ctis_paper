ctis_full_tables <- con_ctis %>% 
  dbListTables() %>% 
  str_subset("full")

ctis_micro_full_tables_df <- tibble(table_name = ctis_full_tables,
                                    date = ymd(str_remove(table_name, "full_")))

ctis_micro_full_estimates_v1_e2 <- ctis_micro_full_tables_df %>% 
  filter(date >= "2021-01-05") %>% 
  mutate(v1_e2_estimates = map(table_name, ctis_micro_get_estimates_v1_urbancity))

v1_e2_estimates_full <- ctis_micro_full_estimates_v1_e2 %>% 
  select(v1_e2_estimates) %>%  
  unnest(v1_e2_estimates) %>% 
  mutate(e2 = factor(e2),
         v1 = factor(v1)) %>% 
  mutate(e2 = fct_recode(e2, 
                         "City" = "1",
                         "Town" = "2",
                         "Village or rural area" = "3"),
         v1 = fct_recode(v1, 
                         "Yes" = "1",
                         "No" = "2"))

vroom_write(v1_e2_estimates_full, 
            here("data/vaccination_urbanicity_estimates.csv"), 
            delim = ",")
