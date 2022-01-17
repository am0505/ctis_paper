#' Clean Population Estimates from raw file
#'
#' @param excel_path Path to Excel File
#'
#' @return
#' @export
#'
#' @examples
clean_pop_estimates <- function(excel_path) {
  
  pop_raw <- read_excel(excel_path,
                        sheet = "total pop",
                        skip = 4) %>%
    clean_names()
  
  names(pop_raw) <- c("state", "pop_male", "pop_female", "pop_person", "popshareind_male", "popshareind_female", "popshareind_person", "sexratiost")
  
  popu_raw <- read_excel(excel_path,
                         sheet = "urban pop",
                         skip = 4) %>%
    clean_names()
  
  names(popu_raw) <- c("state", "popu_male", "popu_female", "popu_person", "popushareind_male", "popushareind_female", "popushareind_person", "sexratioust")
  
  popage_raw <- read_excel(excel_path,
                           sheet = "Age-wise",
                           skip = 5) %>%
    clean_names()
  
  names(popage_raw) <- c("state", "age_group", "pop_person", "pop_male", "pop_female", "popshareind_person", "popshareind_male", "popshareind_female", "sexratio")
  
  pop <- pop_raw %>%
    select(state, pop_male, pop_female, pop_person) %>%
    full_join(popu_raw %>%
                select(state, popu_male, popu_female, popu_person),
              by = "state") %>%
    mutate(popr_male = pop_male - popu_male,
           popr_female = pop_female - popu_female,
           popr_person = pop_person - popu_person) %>%
    mutate(across(where(is.double), ~ .x*1000)) %>%
    mutate(territory_type = case_when(str_detect(state, "\\*") ~ "UT",
                                      TRUE ~ "State")) %>%
    mutate(state = str_remove(state, "\\*"))
  
  pop_share <- pop_raw %>%
    select(state, popshareind_male, popshareind_female, popshareind_person, sexratiost) %>%
    full_join(popu_raw %>%
                select(state, popushareind_male, popushareind_female, popushareind_person, sexratioust),
              by = "state") %>%
    mutate(territory_type = case_when(str_detect(state, "\\*") ~ "UT",
                                      TRUE ~ "State")) %>%
    mutate(state = str_remove(state, "\\*"))
  
  popage <- popage_raw %>%
    select(state, age_group, starts_with("pop_")) %>%
    mutate(state = str_to_title(state)) %>%
    mutate(across(where(is.double), ~ .x*1000)) %>%
    mutate(state = case_when(state == "Nct Of Delhi" ~ "NCT of Delhi",
                             state == "Jammu & Kashmir (Ut)" ~ "Jammu & Kashmir(UT)",
                             TRUE ~ state))
  
  popage_share <- popage_raw %>%
    select(state, age_group, starts_with("popshareind_"), sexratio) %>%
    mutate(state = str_to_title(state)) %>%
    mutate(state = case_when(state == "Nct Of Delhi" ~ "NCT of Delhi",
                             state == "Jammu & Kashmir (Ut)" ~ "Jammu & Kashmir(UT)",
                             TRUE ~ state))
  
  pop_lst <- tibble::lst(pop, pop_share, popage, popage_share)
  
  return(pop_lst)
  
}
