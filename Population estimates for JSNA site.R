# This uses the easypackages package to load several libraries at once. Note: it should only be used when you are confident that all packages are installed as it will be more difficult to spot load errors compared to loading each one individually.
library(easypackages)

libraries(c("readxl", "readr", "plyr", "dplyr", "ggplot2", "png", "tidyverse", "reshape2", "scales", "viridis", "rgdal", "officer", "flextable", "tmaptools", "lemon", "fingertipsR", "PHEindicatormethods", 'jsonlite'))

capwords = function(s, strict = FALSE) {
  cap = function(s) paste(toupper(substring(s, 1, 1)),
                          {s = substring(s, 2); if(strict) tolower(s) else s},sep = "", collapse = " " )
  sapply(strsplit(s, split = " "), cap, USE.NAMES = !is.null(names(s)))}

github_repo_dir <- "~/Documents/Repositories/Population-pyramids"

NOMIS_codes <- read_csv(paste0(github_repo_dir,"/NOMIS_area_codes.csv"), col_types = cols(GEOGRAPHY_CODE = col_character(),GEOGRAPHY_NAME = col_character(),GEOGRAPHY = col_double(),  Area_Type = col_character()))

Lookup <- read_csv("./Projecting-Health/Area_lookup_table.csv", col_types = cols(LTLA17CD = col_character(),LTLA17NM = col_character(), UTLA17CD = col_character(),  UTLA17NM = col_character(), FID = col_character()))
Areas <- read_csv("./Projecting-Health/Area_types_table.csv", col_types = cols(Area_Code = col_character(), Area_Name = col_character(), Area_Type = col_character()))

Areas_to_include <- c("Adur", "Arun", "Chichester", "Crawley", "Horsham", "Mid Sussex", "Worthing", "West Sussex", 'South East', "England")

Chosen_area_codes <- subset(Areas, Area_Name %in% Areas_to_include) %>% 
  left_join(NOMIS_codes[c("GEOGRAPHY", "GEOGRAPHY_CODE")], by = c("Area_Code" = "GEOGRAPHY_CODE"))

ONS_projections_SYOA <- data.frame(GEOGRAPHY = double(),GEOGRAPHY_NAME = character(), GEOGRAPHY_CODE = character(),PROJECTED_YEAR_NAME = double(),GENDER_NAME = character(),C_AGE_NAME = character(),  MEASURES_NAME = character(), OBS_VALUE = double(), OBS_STATUS_NAME = character(), RECORD_COUNT = double())

for(i in 0:floor(as.numeric(read_csv(paste0("http://www.nomisweb.co.uk/api/v01/dataset/NM_2006_1.data.csv?geography=",paste(as.numeric(Chosen_area_codes$GEOGRAPHY), collapse = ","),"&gender=1,2&c_age=101...191&measures=20100&select=record_count&recordlimit=1"), col_types = cols(RECORD_COUNT = col_double())))/25000)){
  df <- read_csv(url(paste0("http://www.nomisweb.co.uk/api/v01/dataset/NM_2006_1.data.csv?geography=",paste(as.numeric(Chosen_area_codes$GEOGRAPHY), collapse = ","),"&gender=1,2&c_age=101...191&measures=20100&select=geography,geography_name,geography_code,projected_year_name,gender_name,c_age_name,measures_name,obs_value,obs_status_name,record_count&recordoffset=", 25000 * i)), col_types = cols(GEOGRAPHY = col_double(),GEOGRAPHY_NAME = col_character(),  GEOGRAPHY_CODE = col_character(),PROJECTED_YEAR_NAME = col_double(), GENDER_NAME = col_character(),C_AGE_NAME = col_character(), MEASURES_NAME = col_character(),OBS_VALUE = col_double(), OBS_STATUS_NAME = col_character(),RECORD_COUNT = col_double()))
  
  ONS_projections_SYOA <- ONS_projections_SYOA %>% 
    bind_rows(df)
}

ONS_projections_SYOA <- ONS_projections_SYOA %>% 
  rename(AREA_CODE = GEOGRAPHY_CODE,
         AREA_NAME = GEOGRAPHY_NAME,
         SEX = GENDER_NAME) %>% 
  mutate(SEX = ifelse(SEX == "Male", "males", ifelse(SEX == "Female", "females", NA))) %>% 
  mutate(AGE_GROUP = gsub("Age ", "", C_AGE_NAME)) %>% 
  select(AREA_CODE, AREA_NAME, SEX, AGE_GROUP, PROJECTED_YEAR_NAME, OBS_VALUE) %>% 
  spread(PROJECTED_YEAR_NAME, OBS_VALUE) %>% 
  mutate(AGE_GROUP  = ifelse(AGE_GROUP == "Aged 90+", "90 and over", AGE_GROUP))

ONS_projection_1941_quinary <- ONS_projections_SYOA %>% 
  filter(AGE_GROUP != "All ages") %>% 
  mutate(Age = as.numeric(gsub(" and over", "", AGE_GROUP))) %>% 
  mutate(`Age group` = ifelse(Age <= 4, "0-4 years", ifelse(Age <= 9, "5-9 years", ifelse(Age <= 14, "10-14 years", ifelse(Age <= 19, "15-19 years", ifelse(Age <= 24, "20-24 years", ifelse(Age <= 29, "25-29 years",ifelse(Age <= 34, "30-34 years", ifelse(Age <= 39, "35-39 years",ifelse(Age <= 44, "40-44 years", ifelse(Age <= 49, "45-49 years",ifelse(Age <= 54, "50-54 years", ifelse(Age <= 59, "55-59 years",ifelse(Age <= 64, "60-64 years", ifelse(Age <= 69, "65-69 years",ifelse(Age <= 74, "70-74 years", ifelse(Age <= 79, "75-79 years",ifelse(Age <= 84, "80-84 years", ifelse(Age <= 89, "85-89 years", "90+ years"))))))))))))))))))) %>% 
  group_by(AREA_NAME, AREA_CODE, SEX, `Age group`) %>% 
  summarise(`2019` = sum(`2019`, na.rm = TRUE),
            `2020` = sum(`2020`, na.rm = TRUE),
            `2021` = sum(`2021`, na.rm = TRUE),
            `2022` = sum(`2022`, na.rm = TRUE),
            `2023` = sum(`2023`, na.rm = TRUE),
            `2024` = sum(`2024`, na.rm = TRUE),
            `2025` = sum(`2025`, na.rm = TRUE),
            `2026` = sum(`2026`, na.rm = TRUE),
            `2027` = sum(`2027`, na.rm = TRUE),
            `2028` = sum(`2028`, na.rm = TRUE),
            `2029` = sum(`2029`, na.rm = TRUE),
            `2030` = sum(`2030`, na.rm = TRUE),
            `2031` = sum(`2031`, na.rm = TRUE),
            `2032` = sum(`2032`, na.rm = TRUE),
            `2033` = sum(`2033`, na.rm = TRUE),
            `2034` = sum(`2034`, na.rm = TRUE),
            `2035` = sum(`2035`, na.rm = TRUE),
            `2036` = sum(`2036`, na.rm = TRUE),
            `2037` = sum(`2037`, na.rm = TRUE),
            `2038` = sum(`2038`, na.rm = TRUE),
            `2039` = sum(`2039`, na.rm = TRUE),
            `2040` = sum(`2040`, na.rm = TRUE),
            `2041` = sum(`2041`, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(SEX = capwords(SEX)) %>% 
  rename(Area_name = AREA_NAME,
         Area_code = AREA_CODE,
         Sex = SEX) %>% 
  mutate(Sex = ifelse(Sex == "Females", "Female", ifelse(Sex == "Males", "Male", Sex))) %>% 
  gather(Year, Population, `2019`:`2041`, factor_key = TRUE) %>% 
  mutate(Data_type = "Projected - ONS",
         Age_band_type = "5 years")

ONS_projection_1941_10_year <- ONS_projections_SYOA %>% 
  filter(AGE_GROUP != "All ages") %>% 
  mutate(Age = as.numeric(gsub(" and over", "", AGE_GROUP))) %>% 
  mutate(`Age group` = ifelse(Age <= 9, "0-9 years", ifelse(Age <= 19, "10-19 years", ifelse(Age <= 29, "20-29 years", ifelse(Age <= 39, "30-39 years", ifelse(Age <= 49, "40-49 years", ifelse(Age <= 59, "50-59 years",ifelse(Age <= 69, "60-69 years", ifelse(Age <= 79, "70-79 years",ifelse(Age <= 89, "80-89 years", "90+ years")))))))))) %>% 
  group_by(AREA_NAME, AREA_CODE, SEX, `Age group`) %>% 
  summarise(`2019` = sum(`2019`, na.rm = TRUE),
            `2020` = sum(`2020`, na.rm = TRUE),
            `2021` = sum(`2021`, na.rm = TRUE),
            `2022` = sum(`2022`, na.rm = TRUE),
            `2023` = sum(`2023`, na.rm = TRUE),
            `2024` = sum(`2024`, na.rm = TRUE),
            `2025` = sum(`2025`, na.rm = TRUE),
            `2026` = sum(`2026`, na.rm = TRUE),
            `2027` = sum(`2027`, na.rm = TRUE),
            `2028` = sum(`2028`, na.rm = TRUE),
            `2029` = sum(`2029`, na.rm = TRUE),
            `2030` = sum(`2030`, na.rm = TRUE),
            `2031` = sum(`2031`, na.rm = TRUE),
            `2032` = sum(`2032`, na.rm = TRUE),
            `2033` = sum(`2033`, na.rm = TRUE),
            `2034` = sum(`2034`, na.rm = TRUE),
            `2035` = sum(`2035`, na.rm = TRUE),
            `2036` = sum(`2036`, na.rm = TRUE),
            `2037` = sum(`2037`, na.rm = TRUE),
            `2038` = sum(`2038`, na.rm = TRUE),
            `2039` = sum(`2039`, na.rm = TRUE),
            `2040` = sum(`2040`, na.rm = TRUE),
            `2041` = sum(`2041`, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(SEX = capwords(SEX)) %>% 
  rename(Area_name = AREA_NAME,
         Area_code = AREA_CODE,
         Sex = SEX) %>% 
  mutate(Sex = ifelse(Sex == "Females", "Female", ifelse(Sex == "Males", "Male", Sex))) %>% 
  gather(Year, Population, `2019`:`2041`, factor_key = TRUE) %>% 
  mutate(Data_type = "Projected - ONS",
         Age_band_type = "10 years")

ONS_projection_1941_broad <- ONS_projections_SYOA %>% 
  filter(AGE_GROUP != "All ages") %>% 
  mutate(Age = as.numeric(gsub(" and over", "", AGE_GROUP))) %>% 
  mutate(`Age group` = ifelse(Age <= 15, "0-15 years", ifelse(Age <= 64, "16-64 years", "65+ years"))) %>% 
  group_by(AREA_NAME, AREA_CODE, SEX, `Age group`) %>% 
  summarise(`2019` = sum(`2019`, na.rm = TRUE),
            `2020` = sum(`2020`, na.rm = TRUE),
            `2021` = sum(`2021`, na.rm = TRUE),
            `2022` = sum(`2022`, na.rm = TRUE),
            `2023` = sum(`2023`, na.rm = TRUE),
            `2024` = sum(`2024`, na.rm = TRUE),
            `2025` = sum(`2025`, na.rm = TRUE),
            `2026` = sum(`2026`, na.rm = TRUE),
            `2027` = sum(`2027`, na.rm = TRUE),
            `2028` = sum(`2028`, na.rm = TRUE),
            `2029` = sum(`2029`, na.rm = TRUE),
            `2030` = sum(`2030`, na.rm = TRUE),
            `2031` = sum(`2031`, na.rm = TRUE),
            `2032` = sum(`2032`, na.rm = TRUE),
            `2033` = sum(`2033`, na.rm = TRUE),
            `2034` = sum(`2034`, na.rm = TRUE),
            `2035` = sum(`2035`, na.rm = TRUE),
            `2036` = sum(`2036`, na.rm = TRUE),
            `2037` = sum(`2037`, na.rm = TRUE),
            `2038` = sum(`2038`, na.rm = TRUE),
            `2039` = sum(`2039`, na.rm = TRUE),
            `2040` = sum(`2040`, na.rm = TRUE),
            `2041` = sum(`2041`, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(SEX = capwords(SEX)) %>% 
  rename(Area_name = AREA_NAME,
         Area_code = AREA_CODE,
         Sex = SEX) %>% 
  mutate(Sex = ifelse(Sex == "Females", "Female", ifelse(Sex == "Males", "Male", Sex))) %>% 
  gather(Year, Population, `2019`:`2041`, factor_key = TRUE) %>% 
  mutate(Data_type = "Projected - ONS",
         Age_band_type = "broad years")

Areas_projections_file <- ONS_projection_1941_quinary %>% 
  bind_rows(ONS_projection_1941_10_year) %>% 
  bind_rows(ONS_projection_1941_broad) %>% 
  left_join(Areas, by = c("Area_name" = "Area_Name")) %>% 
  select(Area_name, Area_Code, Area_Type, Sex, `Age group`,Age_band_type, Year, Population, Data_type) %>% 
  rename(Age_group = `Age group`,
         Area_Name = Area_name)

ONS_mye_SYOA <- data.frame(DATE_NAME = double(), GEOGRAPHY = double(),GEOGRAPHY_NAME = character(), GEOGRAPHY_CODE = character(), GENDER_NAME = character(),C_AGE_NAME = character(),  MEASURES_NAME = character(), OBS_VALUE = double(), OBS_STATUS_NAME = character(), RECORD_COUNT = double())

for(i in 0:floor(as.numeric(read_csv(url(paste0("http://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv?geography=",paste(as.numeric(Chosen_area_codes$GEOGRAPHY), collapse = ","),"&gender=1,2&c_age=101...191&measures=20100&select=record_count&recordlimit=1")), col_types = cols(RECORD_COUNT = col_double())))/25000)){
  df <- read_csv(url(paste0("http://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv?geography=",paste(as.numeric(Chosen_area_codes$GEOGRAPHY), collapse = ","),"&gender=1,2&c_age=101...191&measures=20100&select=date_name,geography,geography_name,geography_code,gender_name,c_age_name,measures_name,obs_value,obs_status_name,record_count&recordoffset=", 25000 * i)), col_types = cols(DATE_NAME = col_double(), GEOGRAPHY = col_double(),GEOGRAPHY_NAME = col_character(),  GEOGRAPHY_CODE = col_character(), GENDER_NAME = col_character(),C_AGE_NAME = col_character(), MEASURES_NAME = col_character(),OBS_VALUE = col_double(), RECORD_COUNT = col_double()))
  
  ONS_mye_SYOA <- ONS_mye_SYOA %>% 
    bind_rows(df)
}

NOMIS_mye_df <- ONS_mye_SYOA %>% 
  rename(AREA_CODE = GEOGRAPHY_CODE,
         AREA_NAME = GEOGRAPHY_NAME,
         SEX = GENDER_NAME) %>% 
  mutate(SEX = ifelse(SEX == "Male", "males", ifelse(SEX == "Female", "females", NA))) %>% 
  mutate(AGE_GROUP = gsub("Age ", "", C_AGE_NAME)) %>% 
  select(AREA_CODE, AREA_NAME, SEX, AGE_GROUP, DATE_NAME, OBS_VALUE) %>% 
  spread(DATE_NAME, OBS_VALUE) %>% 
  mutate(AGE_GROUP  = ifelse(AGE_GROUP == "Aged 90+", "90 and over", AGE_GROUP))

ONS_MYE_quinary <- NOMIS_mye_df %>% 
  filter(AGE_GROUP != "All ages") %>% 
  mutate(Age = as.numeric(gsub(" and over", "", AGE_GROUP))) %>% 
  mutate(`Age group` = ifelse(Age <= 4, "0-4 years", ifelse(Age <= 9, "5-9 years", ifelse(Age <= 14, "10-14 years", ifelse(Age <= 19, "15-19 years", ifelse(Age <= 24, "20-24 years", ifelse(Age <= 29, "25-29 years",ifelse(Age <= 34, "30-34 years", ifelse(Age <= 39, "35-39 years",ifelse(Age <= 44, "40-44 years", ifelse(Age <= 49, "45-49 years",ifelse(Age <= 54, "50-54 years", ifelse(Age <= 59, "55-59 years",ifelse(Age <= 64, "60-64 years", ifelse(Age <= 69, "65-69 years",ifelse(Age <= 74, "70-74 years", ifelse(Age <= 79, "75-79 years",ifelse(Age <= 84, "80-84 years", ifelse(Age <= 89, "85-89 years", "90+ years"))))))))))))))))))) %>% 
  group_by(AREA_NAME, AREA_CODE, SEX, `Age group`) %>% 
  summarise(`2001` = sum(`2001`, na.rm = TRUE),
            `2002` = sum(`2002`, na.rm = TRUE),
            `2003` = sum(`2003`, na.rm = TRUE),
            `2004` = sum(`2004`, na.rm = TRUE),
            `2005` = sum(`2005`, na.rm = TRUE),
            `2006` = sum(`2006`, na.rm = TRUE),
            `2007` = sum(`2007`, na.rm = TRUE),
            `2008` = sum(`2008`, na.rm = TRUE),
            `2009` = sum(`2009`, na.rm = TRUE),
            `2010` = sum(`2010`, na.rm = TRUE),
            `2011` = sum(`2011`, na.rm = TRUE),
            `2012` = sum(`2012`, na.rm = TRUE),
            `2013` = sum(`2013`, na.rm = TRUE),
            `2014` = sum(`2014`, na.rm = TRUE),
            `2015` = sum(`2015`, na.rm = TRUE),
            `2016` = sum(`2016`, na.rm = TRUE),
            `2017` = sum(`2017`, na.rm = TRUE),
            `2018` = sum(`2018`, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(SEX = capwords(SEX)) %>% 
  rename(Area_name = AREA_NAME,
         Area_code = AREA_CODE,
         Sex = SEX) %>% 
  mutate(Sex = ifelse(Sex == "Females", "Female", ifelse(Sex == "Males", "Male", Sex))) %>% 
  gather(Year, Population, `2001`:`2018`, factor_key = TRUE) %>% 
  mutate(Data_type = "Estimates - ONS",
         Age_band_type = "5 years")

ONS_MYE_10_year <- NOMIS_mye_df %>% 
  filter(AGE_GROUP != "All ages") %>% 
  mutate(Age = as.numeric(gsub(" and over", "", AGE_GROUP))) %>% 
  mutate(`Age group` = ifelse(Age <= 9, "0-9 years", ifelse(Age <= 19, "10-19 years", ifelse(Age <= 29, "20-29 years", ifelse(Age <= 39, "30-39 years", ifelse(Age <= 49, "40-49 years", ifelse(Age <= 59, "50-59 years",ifelse(Age <= 69, "60-69 years", ifelse(Age <= 79, "70-79 years",ifelse(Age <= 89, "80-89 years", "90+ years")))))))))) %>% 
  group_by(AREA_NAME, AREA_CODE, SEX, `Age group`) %>% 
  summarise(`2001` = sum(`2001`, na.rm = TRUE),
            `2002` = sum(`2002`, na.rm = TRUE),
            `2003` = sum(`2003`, na.rm = TRUE),
            `2004` = sum(`2004`, na.rm = TRUE),
            `2005` = sum(`2005`, na.rm = TRUE),
            `2006` = sum(`2006`, na.rm = TRUE),
            `2007` = sum(`2007`, na.rm = TRUE),
            `2008` = sum(`2008`, na.rm = TRUE),
            `2009` = sum(`2009`, na.rm = TRUE),
            `2010` = sum(`2010`, na.rm = TRUE),
            `2011` = sum(`2011`, na.rm = TRUE),
            `2012` = sum(`2012`, na.rm = TRUE),
            `2013` = sum(`2013`, na.rm = TRUE),
            `2014` = sum(`2014`, na.rm = TRUE),
            `2015` = sum(`2015`, na.rm = TRUE),
            `2016` = sum(`2016`, na.rm = TRUE),
            `2017` = sum(`2017`, na.rm = TRUE),
            `2018` = sum(`2018`, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(SEX = capwords(SEX)) %>% 
  rename(Area_name = AREA_NAME,
         Area_code = AREA_CODE,
         Sex = SEX) %>% 
  mutate(Sex = ifelse(Sex == "Females", "Female", ifelse(Sex == "Males", "Male", Sex))) %>% 
  gather(Year, Population, `2001`:`2018`, factor_key = TRUE) %>% 
  mutate(Data_type = "Estimates - ONS",
         Age_band_type = "10 years")

ONS_MYE_broad <- NOMIS_mye_df %>% 
  filter(AGE_GROUP != "All ages") %>% 
  mutate(Age = as.numeric(gsub(" and over", "", AGE_GROUP))) %>% 
  mutate(`Age group` = ifelse(Age <= 15, "0-15 years", ifelse(Age <= 64, "16-64 years", "65+ years"))) %>% 
  group_by(AREA_NAME, AREA_CODE, SEX, `Age group`) %>% 
  summarise(`2001` = sum(`2001`, na.rm = TRUE),
            `2002` = sum(`2002`, na.rm = TRUE),
            `2003` = sum(`2003`, na.rm = TRUE),
            `2004` = sum(`2004`, na.rm = TRUE),
            `2005` = sum(`2005`, na.rm = TRUE),
            `2006` = sum(`2006`, na.rm = TRUE),
            `2007` = sum(`2007`, na.rm = TRUE),
            `2008` = sum(`2008`, na.rm = TRUE),
            `2009` = sum(`2009`, na.rm = TRUE),
            `2010` = sum(`2010`, na.rm = TRUE),
            `2011` = sum(`2011`, na.rm = TRUE),
            `2012` = sum(`2012`, na.rm = TRUE),
            `2013` = sum(`2013`, na.rm = TRUE),
            `2014` = sum(`2014`, na.rm = TRUE),
            `2015` = sum(`2015`, na.rm = TRUE),
            `2016` = sum(`2016`, na.rm = TRUE),
            `2017` = sum(`2017`, na.rm = TRUE),
            `2018` = sum(`2018`, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(SEX = capwords(SEX)) %>% 
  rename(Area_name = AREA_NAME,
         Area_code = AREA_CODE,
         Sex = SEX) %>% 
  mutate(Sex = ifelse(Sex == "Females", "Female", ifelse(Sex == "Males", "Male", Sex))) %>% 
  gather(Year, Population, `2001`:`2018`, factor_key = TRUE) %>% 
  mutate(Data_type = "Estimates - ONS",
         Age_band_type = "broad years")

Areas_estimates_file <- ONS_MYE_quinary %>% 
  bind_rows(ONS_MYE_10_year) %>% 
  bind_rows(ONS_MYE_broad) %>% 
  left_join(Areas, by = c("Area_name" = "Area_Name")) %>% 
  select(Area_name, Area_Code, Area_Type, Sex, `Age group`,Age_band_type, Year, Population, Data_type) %>% 
  rename(Age_group = `Age group`,
         Area_Name = Area_name)

Areas_data_file <- Areas_estimates_file %>% 
  bind_rows(Areas_projections_file) %>% 
  group_by(Area_Name, Sex, Age_group, Age_band_type) %>% 
  arrange(Year) %>% 
  mutate(Annual_change = Population - lag(Population)) %>% 
  mutate(Annual_change = replace_na(Annual_change, 0)) %>% 
  ungroup()

Areas_data_file %>% 
  write.csv(paste0(github_repo_dir,'/Areas_data_file.csv'))
  
Areas_data_file %>% 
  filter(Age_band_type == '5 years') %>% 
  select(-c(Area_Code, Area_Type, Age_band_type, Data_type)) %>% 
  toJSON() %>% 
  write_lines(paste0(github_repo_dir,'/area_population_quinary_df.json'))

Areas_data_file %>% 
  filter(Age_band_type == 'broad years') %>% 
  select(-c(Area_Code, Area_Type, Age_band_type, Data_type)) %>% 
  toJSON() %>% 
  write_lines(paste0(github_repo_dir,'/area_population_broad_df.json'))

Areas_data_file %>% 
  filter(Age_band_type == 'broad years') %>% 
  group_by(Area_Name, Year, Sex) %>% 
  summarise(Population = sum(Population)) %>% 
  toJSON() %>% 
  write_lines(paste0(github_repo_dir,'/area_population_totals_df.json'))

# Components of change ####

# For West Sussex and Eastwards there dont appear to be any changes and we'll use the latest boundary codes
# download.file("https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/populationestimatesforukenglandandwalesscotlandandnorthernireland/mid2001tomid2018detailedtimeseries/ukdetailedtimeseries20012018.zip", paste0(github_repo_dir, "/Components_of_change_01_18.zip"), mode = "wb")

# unzip(paste0(github_repo_dir,"/Components_of_change_01_18.zip"), exdir = github_repo_dir)

Component_change <- read_csv("./Migration_flow/MYEB3_summary_components_of_change_series_UK_(2018_geog19).csv", col_types = cols(.default = col_double(),  ladcode19 = col_character(),  laname19 = col_character(),  country = col_character())) %>%
  gather(key = 'Variable', value = 'Value', 4:ncol(.)) %>%
  mutate(Year = substr(Variable, nchar(Variable)-3, nchar(Variable))) %>%
  mutate(Variable = substr(Variable, 0, nchar(Variable)-5)) %>%
  spread(key = Variable, value = Value) %>%
  mutate(country = ifelse(country == "E", "England", ifelse(country == "W", "Wales", NA))) %>% 
  rename(Area_code = ladcode19) %>% 
  rename(Area_name = laname19) %>% 
  mutate(births_per_1000 = (births / population) * 1000) %>% 
  mutate(deaths_per_1000 = (deaths / population) * 1000) %>% 
  mutate(internal_out_per_1000 = (internal_out / population) * 1000) %>% 
  mutate(internal_in_per_1000 = (internal_in / population) * 1000) %>% 
  mutate(international_out_per_1000 = (international_out / population) * 1000) %>% 
  mutate(international_in_per_1000 = (international_in/ population) * 1000) %>% 
  filter(Area_name %in% Areas_to_include) %>% 
  select(-c(Area_code, country)) %>% 
  group_by(Area_name) %>% 
  mutate(pop_change = population - lag(population)) %>% 
  ungroup()

WSx_component_change <- Component_change %>% 
  group_by(Year) %>% 
  summarise(births = sum(births, na.rm = TRUE),
            deaths = sum(deaths, na.rm = TRUE),
            internal_in = sum(internal_in, na.rm = TRUE),
            internal_net = sum(internal_net, na.rm = TRUE),
            internal_out = sum(internal_out, na.rm = TRUE),
            international_in = sum(international_in, na.rm = TRUE),
            international_net = sum(international_net, na.rm = TRUE),
            international_out = sum(international_out, na.rm = TRUE),
            natchange = sum(natchange, na.rm = TRUE),
            other_change = sum(other_change, na.rm = TRUE),
            population = sum(population, na.rm = TRUE)) %>% 
  mutate(births_per_1000 = (births / population) * 1000) %>% 
  mutate(deaths_per_1000 = (deaths / population) * 1000) %>% 
  mutate(internal_out_per_1000 = (internal_out / population) * 1000) %>% 
  mutate(internal_in_per_1000 = (internal_in / population) * 1000) %>% 
  mutate(international_out_per_1000 = (international_out / population) * 1000) %>% 
  mutate(international_in_per_1000 = (international_in/ population) * 1000) %>% 
  mutate(Area_name = 'West Sussex') %>% 
  mutate(pop_change = population - lag(population))

Component_change %>% 
  bind_rows(WSx_component_change) %>% 
  toJSON() %>% 
  write_lines(paste0(github_repo_dir,'/area_components_of_change_df.json'))

# Other change- Includes estimated net effect of changes to special populations during the twelve months to mid-year. Special populations comprise prisoner, armed forces and their overseas based dependent populations. It also includes estimated population change not attributed to a specific cause in the twelve months to mid-year and small adjustments necessary to account for issues such as minor LA boundary changes and large postcode areas that overlap LA boundaries.

# Deaths
# Death occurrences in a small minority of cells show a negative count. These are as a result of previously provisional data being updated in subsequent periods to account for late death registrations and reallocated counts.

# We define an internal migrant as someone who moves home from one geographical area to another. This may be between local authorities, regions or countries within the UK. Unlike with international migration, there is no internationally agreed definition.

# Figure 3 shows a comparatively high likelihood of moving for very young children. Part of this may be simply because their parents are at an age where moving is still common. The addition of children to a family may also lead to a move, however, once children are at school moves are much less common, potentially because of the disruption it would cause the children as well as the parents who may be at an age where they’re settled into their career.
#
# It is in early adulthood where most moves occur, with the peak age for moves being 19, the main age at which people leave home for study. There is another smaller peak at age 22; in many cases this will reflect graduates moving for employment, further study, returning to their home address or moving in with a partner.
#
# Levels of movement remain comparatively high through those aged in their 20s and 30s but gradually decline with age. This may reflect people becoming more settled in their employment, in an area or in relationships, as well as because they have school-age children.
#
# However, from those aged in their late 70s onwards, the proportion of people moving rises slightly. There are many reasons why people of this age may wish to move, including being closer to their family, downsizing, or to access support and care.
#
# Figure 4 shows how the latest data have changed in percentage terms compared with the previous 12-month period. The largest increase is at age 68 (an increase of 28% (3,000 moves), due partly because of the large increase in the total number of 68 year-olds in the UK (up 178,000 from the previous 12-month period) as people born in the baby boom following the Second World War reach that age.

# International migration
# Estimates for international in/out/net are adjusted for visitor switcher, migrant switcher, asylum seeker and refugee flows.
#
# Special change
# Net special change figures include the effect of change in the estimated special populations from one year to the next that are reflected in the general population of England and Wales - those joining and leaving the special population will create a resulting inflow and outflow between the general population.

# There were 242 local authorities with more people moving in than out, of which 43 had a net inflow of over 10 people per 1,000. These were predominantly in the South East, South West and East of England.
#
# In the year to mid-2018, there were 140 local authorities with more people moving out than in, of which 30 had a net outflow of more than 10 people per 1,000. Of these 31, there were 19 in London, with the rest predominantly in the south and east.
#
# For the year to mid-2018, London as a whole had an overall net outflow of 11.7 per 1,000 people to other areas of England and Wales (Figure 8). As described in the 2017 mid-year estimates release, there is a distinctive age structure to these moves, with children (aged under 18 years) most likely to leave, followed by adults aged over 25 years. However, there was a net inflow among the 18 to 25 years population. Broadly this corresponds to families with children tending to leave London while young adults aged in their 20s tend to move to London.

# Many of the fastest-growing authorities have high net international migration
#
# Figure 6 shows a cluster of central London boroughs having the highest levels of net international migration in the year to mid-2018. It also shows a scattering of urban centres across England, Wales and Scotland with high international migration. These tend to have large student populations, such as Coventry, Newcastle-upon-Tyne and Oxford (these areas have high numbers of population aged 18 to 24 years and can be seen in Figure 7). However, the notable pattern from the map is that most of the UK has relatively similar levels of net international migration, as was the case in mid-2017.
#
# Internal migration for London continues to be negative
#
# There were 242 local authorities with more people moving in than out, of which 43 had a net inflow of over 10 people per 1,000. These were predominantly in the South East, South West and East of England.
#
# In the year to mid-2018, there were 140 local authorities with more people moving out than in, of which 30 had a net outflow of more than 10 people per 1,000. Of these 31, there were 19 in London, with the rest predominantly in the south and east.
#
# For the year to mid-2018, London as a whole had an overall net outflow of 11.7 per 1,000 people to other areas of England and Wales (Figure 8). As described in the 2017 mid-year estimates release, there is a distinctive age structure to these moves, with children (aged under 18 years) most likely to leave, followed by adults aged over 25 years. However, there was a net inflow among the 18 to 25 years population. Broadly this corresponds to families with children tending to leave London while young adults aged in their 20s tend to move to London.

# Flows are expressed per 1,000 to allow comparison where population sizes differ.

# In every region outside London, there was a net inflow of children and of adults aged 25 to 64 years. This was also true for the 65 years and over age group, except for very small net losses in the West Midlands and the North West.

# Fewest births since 2006
#
# The 744,000 births taking place in the year to mid-2018 are the fewest in any year since 2006. In mid-2012 the number of births peaked at 813,000 and have subsequently decreased by 69,000.
#
# Fertility analysis is based largely on calendar year data, for example, Birth summary tables in England and Wales: 2017. The latest UK data in Vital statistics in the UK: births, deaths and marriages – 2018 update shows that in the calendar years 2012 to 2017, UK total fertility rates decreased from 1.92 children per woman to 1.74. However, the numbers of births are related to both the number of women of fertile ages as well as their levels of fertility.
#
# Highest number of deaths in 18 years
#
# There were 20,000 (3%) more deaths in the year to mid-2018 than in the previous year. The 623,000 deaths in the year to mid-2018 were the most since mid-2000. Since mid-2000, the population of the UK has grown by almost 7.5 million and there are 2.4 million more people aged 65 to 84 years and 489,000 more aged 85 years or over. Further analysis of mortality is available:

# Ageing: number of over-65s continues to increase faster than the rest of the population
#
# The composition of the UK population is determined by the patterns of births, deaths and migration that have taken place in previous years. The result is that the broad age groups in the UK population are changing at different rates, with the number of those aged 65 years and over growing faster than those under 65 years of age:
#
#   the number of children (those aged up to 15 years) increased by 7.8% to 12.6 million between 2008 and 2018
# the working age population (those aged 16 to 64 years) increased by 3.5% to 41.6 million between 2008 and 2018
# number of people aged 65 to 84 years increased by 23.0% to 10.6 million between 2008 and 2018
# the number of people aged 85 years and over increased by 22.8% to 1.6 million between 2008 and 2018
#
# The effects of international immigration to the UK since mid-2008 are visible in the pyramid. For most ages, the peaks and troughs present in the pyramid in mid-2008 are visible in the mid-2018 data, shifted by 10 years. However, for the population aged 22 to 39 years in mid-2018, the pyramid is wider than for the same cohort 10 years previously (when they were aged 12 to 29 years). This change has been generated by net international migration adding to the population.
#
# The population pyramid in Figure 4 is interactive, allowing you to compare the population structures of different areas and over time. This shows that the age structure of different parts of the UK can vary considerably.
#
# For example, in Barking and Dagenham, 27% of the population were aged 0 to 15 years and 9% were aged 65 years and over, while in the newly-formed Dorset unitary authority, 16% of the population were aged 0 to 15 years and 29% were aged 65 years and over. An interactive pyramid that can be customised further is available as part of the Analysis of population estimates (APE) tool.

# Many of the fastest-growing authorities have high net international migration
#
# Figure 6 shows a cluster of central London boroughs having the highest levels of net international migration in the year to mid-2018. It also shows a scattering of urban centres across England, Wales and Scotland with high international migration. These tend to have large student populations, such as Coventry, Newcastle-upon-Tyne and Oxford (these areas have high numbers of population aged 18 to 24 years and can be seen in Figure 7). However, the notable pattern from the map is that most of the UK has relatively similar levels of net international migration, as was the case in mid-2017.

# Small area ####

download.file('https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2flowersuperoutputareamidyearpopulationestimates%2fmid2018sape21dt1a/sape21dt1amid2018on2019lalsoasyoaestimatesformatted.zip', paste0(github_repo_dir, '/lsoa_2018.zip'), mode = 'wb')

unzip('/Users/richtyler/Documents/Repositories/Population-pyramids/lsoa_2018.zip', exdir = github_repo_dir)
              
              
# https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationestimates%2fdatasets%2flowersuperoutputareapopulationdensity%2fmid2018sape21dt11/sape21dt11mid2018lsoapopulationdensity.zip


# The old age dependency ratio measures the number of people of state pension age and over for every 1,000 people of working age (16 to SPA).

# Women's State Pension age increased to 65 between April 2016 and November 2018. From December 2018 the SPA for both men and women will increase to reach 66 by October 2020 (Pensions Act 2011). Between 2026 and 2027 SPA will increase to 67 years for both sexes (Pensions Act 2014), SPA will increase to 68 years for both men and women between 2044 and 2046 (Pensions Act 2007).

# To calculate the population estimated to be of state pension age by year we must use the state pension age matrix.

download.file('https://www.ons.gov.uk/file?uri=%2fpeoplepopulationandcommunity%2fpopulationandmigration%2fpopulationprojections%2fdatasets%2ftableofstatepensionagefactorspensionsact%2f2016based/pensionmatrixfor2016npp.xls',paste0(github_repo_dir, '/Pension_matrix_16_based.xls'), mode = 'wb')

Female_pension_matrix_16_based <- read_excel("/Users/richtyler/Documents/Repositories/Population-pyramids/Pension_matrix_16_based.xls", sheet = "Females 2016 NPPs", skip = 4, n_max = 9) %>% 
  rename('Age' = '...1') %>% 
  mutate(Sex = 'Females') %>% 
  gather(Year, SPA_factor, `2010`:`2046`, factor_key = TRUE)

Male_pension_matrix_16_based <- read_excel("/Users/richtyler/Documents/Repositories/Population-pyramids/Pension_matrix_16_based.xls", sheet = "Males 2016 NPPs", skip = 4, n_max = 9) %>% 
  rename('Age' = '...1') %>% 
  mutate(Sex = 'Males') %>% 
  gather(Year, SPA_factor, `2010`:`2046`, factor_key = TRUE)

Pension_matrix <- Female_pension_matrix_16_based %>% 
  bind_rows(Male_pension_matrix_16_based) %>% 
  mutate(Age = as.numeric(gsub(" and over", "", Age))) %>%  
  mutate(Working_factor = 1 - SPA_factor) %>% 
  mutate(Year = as.numeric(as.character(Year)))

rm(Female_pension_matrix_16_based, Male_pension_matrix_16_based)

# Join to SYOA datasets
OADR_1 <- ONS_projections_SYOA %>% 
  select(-AREA_CODE) %>% 
  gather(key = Year, value = 'Population', `2016`:`2041`, factor_key = FALSE) %>% 
  filter(!(Year %in% c(2016,2017,2018))) %>% 
  mutate(Estimate = 'Projection')

OADR_2<- NOMIS_mye_df %>% 
  select(-AREA_CODE) %>% 
  gather(key = Year, value = 'Population', `1991`:`2018`, factor_key = FALSE) %>% 
  filter(Year >= 2010) %>% 
  mutate(Estimate = 'Mid year estimate')

OADR_1 %>% 
  bind_rows(OADR_2) %>% 
  rename(Sex = SEX,
         Age = AGE_GROUP,
         Area = AREA_NAME) %>% 
  mutate(Age = as.numeric(gsub(" and over", "", Age))) %>% 
  mutate(Year = as.numeric(Year)) %>% 
  mutate(Sex = capwords(Sex, strict = TRUE)) %>% 
  left_join(Pension_matrix, by = c('Age', 'Sex', 'Year')) %>% 
  mutate(SPA_factor = ifelse(is.na(SPA_factor), 0, SPA_factor)) %>% 
  mutate(SPA_factor = ifelse(Age > 68, 1, SPA_factor)) %>% 
  mutate(Working_factor = ifelse(Age >= 16 & Age < 60, 1, Working_factor)) %>% 
  mutate(Working_factor = ifelse(is.na(Working_factor), 0, Working_factor)) %>% 
  mutate(Number_SPA = Population * SPA_factor,
         Number_Workers = Population * Working_factor) %>% 
  group_by(Area, Year, Estimate) %>% 
  summarise(Number_SPA = sum(Number_SPA),
            Number_Workers = sum(Number_Workers)) %>% 
  ungroup() %>% 
  mutate(OADR = Number_SPA / Number_Workers * 1000) %>% 
  toJSON() %>% 
  write_lines(paste0(github_repo_dir,'/area_oadr_df.json'))

# However this measure may become less useful as more people work up to and beyond State Pension age; alternative measures that include economic activity may provide a more meaningful picture of economic dependency.

# The Active Dependency Ratio, which takes into account projected increases in economic activity levels at older ages in the future

# GP Practices ####

# Quarterly publications in January, April, July and October will include Lower Layer Super Output Area (LSOA) populations and a topic of interest.
# 
# GP_num_2019 <- read_csv('https://files.digital.nhs.uk/6D/3857B6/gp-reg-pat-prac-all.csv')
# 
# GP_females_2019_SYOA <- read_csv('https://files.digital.nhs.uk/0C/0DFE1D/gp-reg-pat-prac-sing-age-female.csv')
# GP_females_2019_SYOA <- read_csv('https://files.digital.nhs.uk/47/CCD421/gp-reg-pat-prac-sing-age-male.csv')
# # https://files.digital.nhs.uk/FC/086DD7/gp-reg-pat-prac-lsoa-male-female-jul-19.zip

GP_mapping <- read_csv('https://files.digital.nhs.uk/BA/206EF1/gp-reg-pat-prac-map.csv') %>% 
  select(PRACTICE_CODE, PRACTICE_NAME) %>% 
  rename(Code = PRACTICE_CODE,
         Name = PRACTICE_NAME) %>% 
  mutate(Name = capwords(Name, strict = T)) %>% 
  mutate(Name = gsub(' And ', ' and ', Name))

GP_num_2018 <- read_csv('https://files.digital.nhs.uk/0E/C2DE2B/gp-reg-pat-prac-all.csv') %>% 
  filter(CCG_CODE %in% c('09G', '09X', '09H')) %>% 
  rename(Code = CODE,
         Patients = NUMBER_OF_PATIENTS) %>% 
  left_join(GP_mapping, by = 'Code') %>%
  select(Code, Name, Patients)

GP_num_2018_fsyoa <- read_csv('https://files.digital.nhs.uk/18/02778A/gp-reg-pat-prac-sing-age-female.csv') %>% 
  rename(Sex = SEX,
         Age = AGE,
         Code = ORG_CODE,
         Patients = NUMBER_OF_PATIENTS) %>% 
  left_join(GP_mapping, by = 'Code') %>% 
  filter(CCG_CODE %in% c('09G', '09H', '09X')) %>% 
  filter(Age != 'ALL') %>% 
  mutate(Sex = capwords(Sex, strict = T)) %>% 
  select(Code, Name, Sex, Age, Patients)

GP_num_2018_msyoa <- read_csv('https://files.digital.nhs.uk/DA/60EF8C/gp-reg-pat-prac-sing-age-male.csv') %>% 
  rename(Sex = SEX,
         Age = AGE,
         Code = ORG_CODE,
         Patients = NUMBER_OF_PATIENTS) %>% 
  left_join(GP_mapping, by = 'Code') %>% 
  filter(CCG_CODE %in% c('09G', '09H', '09X')) %>% 
  filter(Age != 'ALL') %>% 
  mutate(Sex = capwords(Sex, strict = T)) %>% 
  select(Code, Name, Sex, Age, Patients)

GP_num_2018_syoa <- GP_num_2018_fsyoa %>% 
  bind_rows(GP_num_2018_msyoa) %>% 
  group_by(Code, Name, Age) %>% 
  summarise(Patients = sum(Patients, na.rm = TRUE)) %>% 
  mutate(Sex = 'All')

download.file('https://files.digital.nhs.uk/D2/1D35F3/gp-reg-pat-prac-lsoa-all-females-males-jul-18.zip', paste0(github_repo_dir, '/gp_lsoa_f.zip'), mode = 'wb')
unzip('/Users/richtyler/Documents/Repositories/Population-pyramids/gp_lsoa_f.zip', exdir = github_repo_dir)

GP_lsoa_f_2018 <- read_csv(paste0(github_repo_dir, '/gp-reg-pat-prac-lsoa-female.csv'))
GP_lsoa_m_2018 <- read_csv(paste0(github_repo_dir, '/gp-reg-pat-prac-lsoa-male.csv'))
GP_lsoa_b_2018 <- read_csv(paste0(github_repo_dir, '/gp-reg-pat-prac-lsoa-all.csv'))
