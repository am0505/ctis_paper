Analysis Pipeline
================
Abhinav Motheram
19/1/2022

# Setup

Set up the workflow pipeline and options. We first load the `targets`
package and remove the potentially outdated workflow.

``` r
library(conflicted)
library(dotenv)

library(targets)
library(tarchetypes)
library(here)
library(purrr, quietly = TRUE)

## renv::install("an0505/ctisglobal")
library(ctisglobal)

library(tidyverse)
library(vroom)
library(janitor)
library(lubridate)
library(readxl)

library(here)

conflict_prefer("filter", "dplyr")
conflict_prefer("lag", "dplyr")


functions <- list.files(here("R"), full.names = TRUE)
walk(functions, source)
```

    ## Establish _targets.R and _targets_r/globals/globals.R.

## Define Targets

## Data Import

### COVID-19 India Targets

``` r
tar_target(
  c19_bharat_data,
  get_covid_bharat_data(),
  cue = tarchetypes::tar_cue_age(
    name = c19_bharat_data,
    age = as.difftime(1, units = "days")
  )
)
```

    ## Establish _targets.R and _targets_r/targets/c19_bharat_data.R.

### Population Targets

``` r
tar_target(
  ind_pop_projections,
  clean_pop_estimates(excel_path = "data/Population projection_2020.xlsx")
)
```

    ## Establish _targets.R and _targets_r/targets/ind_pop_projections.R.

``` r
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
```

    ## Establish _targets.R and _targets_r/targets/ind_pop_adult_projections.R.

### CTIS Targets

``` r
tar_target(
  ctis_public_doc,
  ctis_get_public_apidoc(),
  format = "fst_tbl"
)
```

    ## Establish _targets.R and _targets_r/targets/ctis_public_doc.R.

``` r
tar_target(
  ctis_public_indicators,
  ctis_public_doc %>%
    filter(indicator %in% c("covid", "flu", "anosmia", "vaccine_acpt", "covid_vaccine", "twodoses")) %>%
    pull(indicator)
)
```

    ## Establish _targets.R and _targets_r/targets/ctis_public_indicators.R.

``` r
tar_target(
  ctis_public_regions,
  ctis_get_public_regions(),
  format = "fst_tbl"
)
```

    ## Establish _targets.R and _targets_r/targets/ctis_public_regions.R.

``` r
tar_target(
  ctis_public_regions_india,
  ctis_public_regions %>%
    filter(country == "India") %>%
    pull(region) %>%
    append(NA)
)
```

    ## Establish _targets.R and _targets_r/targets/ctis_public_regions_india.R.

``` r
tar_target(
  ctis_india_public,
  ctis_get_public_data(indicator = ctis_public_indicators, 
                       region = ctis_public_regions_india, 
                       date_end = as.character(Sys.Date() - 3)),
  pattern = cross(ctis_public_indicators, ctis_public_regions_india),
  format = "fst_tbl",
  cue = tarchetypes::tar_cue_age(
    name = ctis_india_public,
    age = as.difftime(1, units = "days")
  )
)
```

    ## Establish _targets.R and _targets_r/targets/ctis_india_public.R.

## Data Cleaning

Merge covid19bharat vaccination data and CTIS vaccination estimates to
form a single table.

``` r
tar_target(
  c19_vaccine_merged,
  merge_vaccine_estimates(c19_bharat_data, 
                          ind_pop_adult_projections,
                          ctis_india_public),
  format = "fst_tbl"
)
```

    ## Establish _targets.R and _targets_r/targets/c19_vaccine_merged.R.

Merge covid19bharat COVID diagnostic data and CTIS CLI estimates to form
a single table.

``` r
tar_target(
  c19_covid_merged,
  merge_covid_estimates(c19_bharat_data,
                        ind_pop_projections,
                        ctis_india_public),
  format = "fst_tbl"
)
```

    ## Establish _targets.R and _targets_r/targets/c19_covid_merged.R.

## Render Report

``` r
tar_render(
  ctis_report,
  here("reports/vaccination_analysis_draft_v4.Rmd"),
  output_format ="all"
)
```

    ## Establish _targets.R and _targets_r/targets/ctis_report.R.

# Run the Pipeline

    ## here() starts at /mnt/am0data/masteram/ncaer/ctis_paper
    ## Registered S3 methods overwritten by 'readr':
    ##   method                    from 
    ##   as.data.frame.spec_tbl_df vroom
    ##   as_tibble.spec_tbl_df     vroom
    ##   format.col_spec           vroom
    ##   print.col_spec            vroom
    ##   print.collector           vroom
    ##   print.date_names          vroom
    ##   print.locale              vroom
    ##   str.col_spec              vroom
    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
    ## ✓ ggplot2 3.3.5     ✓ dplyr   1.0.7
    ## ✓ tibble  3.1.6     ✓ stringr 1.4.0
    ## ✓ tidyr   1.1.4     ✓ forcats 0.5.1
    ## ✓ readr   2.1.1     
    ## [conflicted] Will prefer dplyr::filter over any other package
    ## [conflicted] Will prefer dplyr::lag over any other package
    ## ✓ skip target c19_bharat_data
    ## ✓ skip target ind_pop_adult_projections
    ## ✓ skip target ctis_public_doc
    ## ✓ skip target ind_pop_projections
    ## ✓ skip target ctis_public_regions
    ## ✓ skip target ctis_public_indicators
    ## ✓ skip target ctis_public_regions_india
    ## ✓ skip branch ctis_india_public_35343e11
    ## ✓ skip branch ctis_india_public_8966a27f
    ## ✓ skip branch ctis_india_public_1e42f171
    ## ✓ skip branch ctis_india_public_65ca40ca
    ## ✓ skip branch ctis_india_public_bf56505d
    ## ✓ skip branch ctis_india_public_370cb10d
    ## ✓ skip branch ctis_india_public_bf9a6c57
    ## ✓ skip branch ctis_india_public_9e476a0d
    ## ✓ skip branch ctis_india_public_5b631977
    ## ✓ skip branch ctis_india_public_0b37c9e3
    ## ✓ skip branch ctis_india_public_50b11c78
    ## ✓ skip branch ctis_india_public_14b91e93
    ## ✓ skip branch ctis_india_public_eb697815
    ## ✓ skip branch ctis_india_public_af4f9c26
    ## ✓ skip branch ctis_india_public_c9041694
    ## ✓ skip branch ctis_india_public_eaf3ca1a
    ## ✓ skip branch ctis_india_public_46cde359
    ## ✓ skip branch ctis_india_public_7964fd17
    ## ✓ skip branch ctis_india_public_e7c42ee7
    ## ✓ skip branch ctis_india_public_6357a988
    ## ✓ skip branch ctis_india_public_bb444ad4
    ## ✓ skip branch ctis_india_public_d1260a45
    ## ✓ skip branch ctis_india_public_431f99c4
    ## ✓ skip branch ctis_india_public_01c7594b
    ## ✓ skip branch ctis_india_public_69fb8ea2
    ## ✓ skip branch ctis_india_public_7d69b6bc
    ## ✓ skip branch ctis_india_public_fa540679
    ## ✓ skip branch ctis_india_public_ebda5ce6
    ## ✓ skip branch ctis_india_public_1d705892
    ## ✓ skip branch ctis_india_public_6a8a030e
    ## ✓ skip branch ctis_india_public_4533bf9d
    ## ✓ skip branch ctis_india_public_363a8b60
    ## ✓ skip branch ctis_india_public_d8e8e665
    ## ✓ skip branch ctis_india_public_83e8afcb
    ## ✓ skip branch ctis_india_public_24052ee6
    ## ✓ skip branch ctis_india_public_02c5347e
    ## ✓ skip branch ctis_india_public_ebec3888
    ## ✓ skip branch ctis_india_public_191d12df
    ## ✓ skip branch ctis_india_public_b98b7afb
    ## ✓ skip branch ctis_india_public_9458a78a
    ## ✓ skip branch ctis_india_public_99dc1e9a
    ## ✓ skip branch ctis_india_public_fc564711
    ## ✓ skip branch ctis_india_public_5fb19fb5
    ## ✓ skip branch ctis_india_public_02e882b8
    ## ✓ skip branch ctis_india_public_257dfa52
    ## ✓ skip branch ctis_india_public_d12f0a17
    ## ✓ skip branch ctis_india_public_e0a7eaa4
    ## ✓ skip branch ctis_india_public_45e86f37
    ## ✓ skip branch ctis_india_public_52a21985
    ## ✓ skip branch ctis_india_public_cd33bc01
    ## ✓ skip branch ctis_india_public_540467c2
    ## ✓ skip branch ctis_india_public_aa19d47d
    ## ✓ skip branch ctis_india_public_22529c8a
    ## ✓ skip branch ctis_india_public_c0f7555b
    ## ✓ skip branch ctis_india_public_fc513cf9
    ## ✓ skip branch ctis_india_public_de168fa0
    ## ✓ skip branch ctis_india_public_7bb50c1b
    ## ✓ skip branch ctis_india_public_106f7367
    ## ✓ skip branch ctis_india_public_84660937
    ## ✓ skip branch ctis_india_public_2c740668
    ## ✓ skip branch ctis_india_public_4dcb062b
    ## ✓ skip branch ctis_india_public_5129ffa2
    ## ✓ skip branch ctis_india_public_129eed9f
    ## ✓ skip branch ctis_india_public_5dc398e6
    ## ✓ skip branch ctis_india_public_a4c4f2f5
    ## ✓ skip branch ctis_india_public_4f5b0bfa
    ## ✓ skip branch ctis_india_public_47da911b
    ## ✓ skip branch ctis_india_public_b150f874
    ## ✓ skip branch ctis_india_public_acb56090
    ## ✓ skip branch ctis_india_public_c0f6b565
    ## ✓ skip branch ctis_india_public_8e66709e
    ## ✓ skip branch ctis_india_public_7acc885d
    ## ✓ skip branch ctis_india_public_1528d00d
    ## ✓ skip branch ctis_india_public_45b57012
    ## ✓ skip branch ctis_india_public_546a55e7
    ## ✓ skip branch ctis_india_public_77b5ae77
    ## ✓ skip branch ctis_india_public_d73bd4bc
    ## ✓ skip branch ctis_india_public_efd45931
    ## ✓ skip branch ctis_india_public_57b6789e
    ## ✓ skip branch ctis_india_public_517da947
    ## ✓ skip branch ctis_india_public_dbe194da
    ## ✓ skip branch ctis_india_public_661895ea
    ## ✓ skip branch ctis_india_public_aadba0da
    ## ✓ skip branch ctis_india_public_64186908
    ## ✓ skip branch ctis_india_public_7eeadfa4
    ## ✓ skip branch ctis_india_public_00dbf7a8
    ## ✓ skip branch ctis_india_public_4bb35545
    ## ✓ skip branch ctis_india_public_85b97777
    ## ✓ skip branch ctis_india_public_cffbc4e4
    ## ✓ skip branch ctis_india_public_23c79f77
    ## ✓ skip branch ctis_india_public_9d1fe2dc
    ## ✓ skip branch ctis_india_public_5a9b2ca7
    ## ✓ skip branch ctis_india_public_9b6215b7
    ## ✓ skip branch ctis_india_public_c9bc5788
    ## ✓ skip branch ctis_india_public_b3c7d14f
    ## ✓ skip branch ctis_india_public_216620f7
    ## ✓ skip branch ctis_india_public_5adbca4d
    ## ✓ skip branch ctis_india_public_c02865b6
    ## ✓ skip branch ctis_india_public_a9ec364f
    ## ✓ skip branch ctis_india_public_ee30f9d5
    ## ✓ skip branch ctis_india_public_37494705
    ## ✓ skip branch ctis_india_public_c7ce8105
    ## ✓ skip branch ctis_india_public_8a7dfd3f
    ## ✓ skip branch ctis_india_public_532a43c0
    ## ✓ skip branch ctis_india_public_48b15be5
    ## ✓ skip branch ctis_india_public_23fe4433
    ## ✓ skip branch ctis_india_public_a1db8448
    ## ✓ skip branch ctis_india_public_b2c1ac20
    ## ✓ skip branch ctis_india_public_f1c4f7aa
    ## ✓ skip branch ctis_india_public_1c3fbfb7
    ## ✓ skip branch ctis_india_public_84cc2c8b
    ## ✓ skip branch ctis_india_public_9dc95a20
    ## ✓ skip branch ctis_india_public_3966bf28
    ## ✓ skip branch ctis_india_public_dc865c7c
    ## ✓ skip branch ctis_india_public_c06041d1
    ## ✓ skip branch ctis_india_public_235edbb8
    ## ✓ skip branch ctis_india_public_a91edbf1
    ## ✓ skip branch ctis_india_public_8f8a6f76
    ## ✓ skip branch ctis_india_public_71f70762
    ## ✓ skip branch ctis_india_public_16298731
    ## ✓ skip branch ctis_india_public_46a55111
    ## ✓ skip branch ctis_india_public_36e0bcdd
    ## ✓ skip branch ctis_india_public_9567085e
    ## ✓ skip branch ctis_india_public_c0097ee4
    ## ✓ skip branch ctis_india_public_e8bb2b6f
    ## ✓ skip branch ctis_india_public_f67fa929
    ## ✓ skip branch ctis_india_public_4468c4de
    ## ✓ skip branch ctis_india_public_c6494e6d
    ## ✓ skip branch ctis_india_public_229689d3
    ## ✓ skip branch ctis_india_public_dc1634f1
    ## ✓ skip branch ctis_india_public_d2e474a1
    ## ✓ skip branch ctis_india_public_5b0b29be
    ## ✓ skip branch ctis_india_public_b1469012
    ## ✓ skip branch ctis_india_public_39227efe
    ## ✓ skip branch ctis_india_public_170781e1
    ## ✓ skip branch ctis_india_public_35fb8061
    ## ✓ skip branch ctis_india_public_59e54979
    ## ✓ skip branch ctis_india_public_81964c42
    ## ✓ skip branch ctis_india_public_b23ccd18
    ## ✓ skip branch ctis_india_public_ec3645de
    ## ✓ skip branch ctis_india_public_04891dce
    ## ✓ skip branch ctis_india_public_b5943254
    ## ✓ skip branch ctis_india_public_f669796c
    ## ✓ skip branch ctis_india_public_2114d186
    ## ✓ skip branch ctis_india_public_10579732
    ## ✓ skip branch ctis_india_public_a66293fe
    ## ✓ skip branch ctis_india_public_434b3524
    ## ✓ skip branch ctis_india_public_89d9d268
    ## ✓ skip branch ctis_india_public_f005e078
    ## ✓ skip branch ctis_india_public_2a87d78d
    ## ✓ skip branch ctis_india_public_62d8c3cb
    ## ✓ skip branch ctis_india_public_e29869b1
    ## ✓ skip branch ctis_india_public_bc0c961c
    ## ✓ skip branch ctis_india_public_44c46767
    ## ✓ skip branch ctis_india_public_327e7df4
    ## ✓ skip branch ctis_india_public_f784b816
    ## ✓ skip branch ctis_india_public_a224d914
    ## ✓ skip branch ctis_india_public_6a547d34
    ## ✓ skip branch ctis_india_public_474a9055
    ## ✓ skip branch ctis_india_public_0c7dff3f
    ## ✓ skip branch ctis_india_public_1edfe081
    ## ✓ skip branch ctis_india_public_5c78dcdb
    ## ✓ skip branch ctis_india_public_ca25c240
    ## ✓ skip branch ctis_india_public_dfc5f0d1
    ## ✓ skip branch ctis_india_public_750df1f9
    ## ✓ skip branch ctis_india_public_bf12d376
    ## ✓ skip branch ctis_india_public_ab154e10
    ## ✓ skip branch ctis_india_public_a8f1a5da
    ## ✓ skip branch ctis_india_public_41f548d1
    ## ✓ skip branch ctis_india_public_9622cfa3
    ## ✓ skip branch ctis_india_public_2336b8bf
    ## ✓ skip branch ctis_india_public_b21d8ce6
    ## ✓ skip branch ctis_india_public_082b856a
    ## ✓ skip branch ctis_india_public_977c2daa
    ## ✓ skip branch ctis_india_public_c4a57777
    ## ✓ skip branch ctis_india_public_fdb52453
    ## ✓ skip branch ctis_india_public_ab6be9b5
    ## ✓ skip branch ctis_india_public_b9b52d6a
    ## ✓ skip branch ctis_india_public_44e906f9
    ## ✓ skip branch ctis_india_public_4fff3a18
    ## ✓ skip branch ctis_india_public_b7281be2
    ## ✓ skip branch ctis_india_public_4b178db9
    ## ✓ skip branch ctis_india_public_be31189a
    ## ✓ skip branch ctis_india_public_71e3cef4
    ## ✓ skip branch ctis_india_public_c7caa0a6
    ## ✓ skip branch ctis_india_public_a7acfce2
    ## ✓ skip branch ctis_india_public_2462e2cc
    ## ✓ skip branch ctis_india_public_26ddc995
    ## ✓ skip branch ctis_india_public_e4dccef1
    ## ✓ skip branch ctis_india_public_a4bcdb8f
    ## ✓ skip branch ctis_india_public_d16644f5
    ## ✓ skip branch ctis_india_public_a74384b9
    ## ✓ skip branch ctis_india_public_5002e29b
    ## ✓ skip branch ctis_india_public_de65ec7d
    ## ✓ skip branch ctis_india_public_70c93f9c
    ## ✓ skip branch ctis_india_public_3f01d89f
    ## ✓ skip branch ctis_india_public_91193083
    ## ✓ skip branch ctis_india_public_ec5d6521
    ## ✓ skip pattern ctis_india_public
    ## ✓ skip target c19_vaccine_merged
    ## ✓ skip target c19_covid_merged
    ## • start target ctis_report
    ## Rows: 2152 Columns: 8
    ## -- Column specification --------------------------------------------------------
    ## Delimiter: ","
    ## chr  (2): e2, v1
    ## dbl  (5): proportion, proportion_se, proportion_deff, n, unw_prop
    ## date (1): date
    ## 
    ## i Use `spec()` to retrieve the full column specification for this data.
    ## i Specify the column types or set `show_col_types = FALSE` to quiet this message.
    ## Rows: 75864 Columns: 227
    ## -- Column specification --------------------------------------------------------
    ## Delimiter: ","
    ## chr   (10): survey_region, module, Q_Language, GID_0, GID_1, ISO_3, NAME_0, ...
    ## dbl  (216): survey_version, weight, Finished, intro1, intro2, A1, A2_2_1, A2...
    ## dttm   (1): RecordedDate
    ## 
    ## i Use `spec()` to retrieve the full column specification for this data.
    ## i Specify the column types or set `show_col_types = FALSE` to quiet this message.
    ## Rows: 2152 Columns: 8
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr  (2): e2, v1
    ## dbl  (5): proportion, proportion_se, proportion_deff, n, unw_prop
    ## date (1): date
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
    ## Rows: 75864 Columns: 227
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr   (10): survey_region, module, Q_Language, GID_0, GID_1, ISO_3, NAME_0, ...
    ## dbl  (216): survey_version, weight, Finished, intro1, intro2, A1, A2_2_1, A2...
    ## dttm   (1): RecordedDate
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
    ## Rows: 2152 Columns: 8
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr  (2): e2, v1
    ## dbl  (5): proportion, proportion_se, proportion_deff, n, unw_prop
    ## date (1): date
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
    ## Rows: 75864 Columns: 227
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr   (10): survey_region, module, Q_Language, GID_0, GID_1, ISO_3, NAME_0, ...
    ## dbl  (216): survey_version, weight, Finished, intro1, intro2, A1, A2_2_1, A2...
    ## dttm   (1): RecordedDate
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.
    ## • built target ctis_report
    ## • end pipeline
    ## There were 22 warnings (use warnings() to see them)
