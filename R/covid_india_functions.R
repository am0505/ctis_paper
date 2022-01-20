#' Get COVID-19 Bharat API Documentation Tables
#'
#' @import vroom
#' @import janitor
#' @import lubridate
#' @import httr
#' @import rvest
#'
#' @return
#'
#' @export
#'
#' @examples
get_c19bh_api_tables <- function() {
  
  c19b_api_url <- "https://data.covid19bharat.org/"
  
  html <- read_html(c19b_api_url)
  
  tables <- html %>%
    html_table()
  
  json_tables <- tables[[1]] %>%
    clean_names() %>%
    select(-status)
  
  csv_tables <- tables[[2]] %>%
    clean_names() %>%
    select(-status)
  
  raw_csv_tables <- tables[[3]] %>%
    clean_names() %>%
    select(-status)
  
  c19bh_tidy_tables <- list("json_tables" = json_tables,
                            "csv_tables" = csv_tables,
                            "raw_csv_tables" = raw_csv_tables)
  
  return(c19bh_tidy_tables)
}

#' Create first differences from cumulative data
#'
#' @param .df
#' @param .group
#'
#' @return
#' @export
#'
#' @examples
create_diff <- function(.df, .group) {
  .df %>%
    group_by({{.group}}) %>%
    arrange(date) %>%
    mutate(across(where(is_bare_double), ~ .x - lag(.x), .names = "{.col}_d")) %>%
    ungroup()
}

#' Get COVID-19 India Diagnostic (time series) data at State Level
#'
#' @return
#' @export
#'
#' @examples
get_covid_bharat_data <- function() {
  
  # COVID-19 Bharat API
  ## Working sheets - states, districts, vaccine_doses_administered_statewise
  c19bh_data_st <- vroom("https://data.covid19bharat.org/csv/latest/states.csv") %>%
    clean_names() %>%
    create_diff(.group = state) %>%
    ungroup() %>%
    mutate(state = case_when(state == "India" ~ "All Regions",
                             state == "Delhi" ~ "NCT of Delhi",
                             TRUE ~ state))
  
  c19bh_data_dist <- vroom("https://data.covid19bharat.org/csv/latest/districts.csv") %>%
    clean_names() %>%
    create_diff(.group = state) %>%
    mutate(state = case_when(state == "Delhi" ~ "NCT of Delhi",
                             TRUE ~ state)) 
  
  c19bh_data_vaccine_st <- vroom("http://data.covid19bharat.org/csv/latest/vaccine_doses_statewise_v2.csv") %>%
    clean_names() %>%
    mutate(date = dmy(vaccinated_as_of)) %>%
    create_diff(.group = state) %>%
    mutate(state = case_when(state == "Total" ~ "All Regions",
                             state == "Delhi" ~ "NCT of Delhi",
                             TRUE ~ state)) 
  
  ## Update 25 Dec 2021
  c19bh_cowin_vaccine_data_statewise <-  vroom("http://data.covid19bharat.org/csv/latest/cowin_vaccine_data_statewise.csv") %>%
    clean_names() %>%
    mutate(date = dmy(updated_on)) %>%
    mutate(vaccinations_male = case_when(!is.na(male_doses_administered) ~ male_doses_administered,
                                         is.na(female_doses_administered) ~ female_individuals_vaccinated)) %>%
    mutate(vaccinations_female = case_when(!is.na(female_doses_administered) ~ female_doses_administered,
                                           is.na(female_doses_administered) ~ female_individuals_vaccinated)) %>%
    mutate(vaccinations_transgender = case_when(!is.na(transgender_doses_administered) ~ transgender_doses_administered,
                                                is.na(transgender_doses_administered) ~ transgender_individuals_vaccinated)) %>%
    mutate(vaccinations_y18_44 = case_when(!is.na(x18_44_years_doses_administered) ~ x18_44_years_doses_administered,
                                           is.na(x45_60_years_doses_administered) ~ x45_60_years_individuals_vaccinated)) %>%
    mutate(vaccinations_y45_60 = case_when(!is.na(x45_60_years_doses_administered) ~ x45_60_years_doses_administered,
                                           is.na(x45_60_years_doses_administered) ~ x45_60_years_individuals_vaccinated)) %>%
    mutate(vaccinations_y60_above = case_when(!is.na(x60_years_doses_administered) ~ x60_years_doses_administered,
                                              is.na(x60_years_doses_administered) ~ x60_years_individuals_vaccinated)) %>%
    rename(vaccinations_total = total_doses_administered,
           vaccinations_first_dose = first_dose_administered,
           vaccinations_second_dose = second_dose_administered,
           vaccinations_covaxin = covaxin_doses_administered,
           vaccinations_covishield = covi_shield_doses_administered,
           vaccinations_sputnikv = sputnik_v_doses_administered) %>%
    mutate(aefi = case_when(aefi == 0 & (date >= "2021-08-15" & date <= "2021-08-21") ~ NA_real_,
                            aefi == 0 & date == "2021-09-12" ~ NA_real_,
                            TRUE ~ aefi)) %>%
    select(date, state, aefi, starts_with("vaccinations")) %>%
    mutate(state = case_when(state == "India" ~ "All Regions",
                             state == "Delhi" ~ "NCT of Delhi",
                             TRUE ~ state)) 
  
  c19bh_cowin_vaccine_data_statewise_d <- c19bh_cowin_vaccine_data_statewise %>%
    create_diff(.group = state) %>%
    select(date, state, aefi_d, ends_with("_d"))
  
  # c19bh_cowin_vaccine_data_districtwise <-  vroom("http://data.covid19bharat.org/csv/latest/cowin_vaccine_data_districtwise.csv") #%>%
  #   clean_names() %>%
  #   mutate(date = dmy(updated_on))
  
  c19bh_data <- lst(c19bh_data_st,
                    c19bh_data_dist,
                    c19bh_data_vaccine_st,
                    c19bh_cowin_vaccine_data_statewise,
                    c19bh_cowin_vaccine_data_statewise_d)

  return(c19bh_data)
  
}

