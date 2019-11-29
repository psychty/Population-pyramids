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
