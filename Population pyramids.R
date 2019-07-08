library(easypackages)

# This uses the easypackages package to load several libraries at once. Note: it should only be used when you are confident that all packages are installed as it will be more difficult to spot load errors compared to loading each one individually.
libraries(c("readxl", "readr", "plyr", "dplyr", "ggplot2", "png", "tidyverse", "reshape2", "scales", "viridis", "rgdal", "officer", "flextable", "tmaptools", "lemon", "fingertipsR", "PHEindicatormethods", "xlsx"))

# If you have downloaded/cloned the github repo for this project you will need to make sure the filepath is recorded in the object github_repo_dir
github_repo_dir <- "~/Documents/Repositories/Projecting-Health"

# If you have run the other scripts you should have a folder in your working directory called 'Projecting-Health'. If you do not have one then it will be created
if(!(file.exists(paste0("./Projecting-Health")))){
  dir.create(paste0("./Projecting-Health"))
}

# If there is no folder for images create one
if(!(file.exists(paste0("./Projecting-Health/Population_pyramid_image_files")))){
  dir.create(paste0("./Projecting-Health/Population_pyramid_image_files"))
}

# Create a modified theme for line graphs (i.e. put the legend at the bottom)

pyramid_theme = function(){
  theme( 
    plot.background = element_rect(fill = "white", colour = "#ffffff"), 
    panel.background = element_rect(fill = "white"), 
    axis.text = element_text(colour = "#000000", size = 7), 
    plot.title = element_text(colour = "#000000", face = "bold", size = 11, vjust = 1), 
    plot.subtitle = element_text(colour = "#000000", face = "italic", size = 8, vjust = 1),
    axis.title = element_text(colour = "#000000", face = "bold", size = 8),     
    panel.grid.major.x = element_line(colour = "#E2E2E3", linetype = "longdash", size = 0.2), 
    panel.grid.minor.x = element_blank(), 
    panel.grid.major.y = element_blank(), 
    panel.grid.minor.y = element_blank(), 
    strip.text = element_text(colour = "white"), 
    strip.background = element_rect(fill = "#000000"), 
    axis.ticks = element_line(colour = "#000000"),
    axis.ticks.y = element_blank()
  ) 
}

# Axis labels can be formated in a number of ways. We need to have the absolute number (-10000 people would look weird) and it would also be good to include the comma separator (10,000 is easier to read than 10000).
# Using ggplot you can format both of these (by using labels = abs and labels = comma, respectively) but you cannot do them at the same time.

# So we need to create a function that does both
abs_comma <- function (x, ...) {
  format(abs(x), ..., big.mark = ",", scientific = FALSE, trim = TRUE)}

# You can also hijack the percent function and return axes labels with "%" as a suffix (or you could do any suffix)
abs_percent <- function (x, ...) {
  if (length(x) == 0) 
    return(character())
  paste0(comma(abs(x) * 100), "%")}

Areas_to_include <- c("Eastbourne", "Hastings", "Lewes","Rother", "Wealden","Adur", "Arun", "Chichester", "Crawley", "Horsham", "Mid Sussex", "Worthing", "Brighton and Hove", "NHS Brighton and Hove CCG", "NHS Coastal West Sussex CCG", "NHS Crawley CCG","NHS Eastbourne, Hailsham and Seaford CCG", "NHS Hastings and Rother CCG","NHS High Weald Lewes Havens CCG", "NHS Horsham and Mid Sussex CCG", "West Sussex", "East Sussex", "England")

Comparator_x <- "England"

if(!(Comparator_x %in% Areas_to_include)){
  print(paste0("The comparator you selected (", Comparator_x, ") is not in the list of areas for which we have data. Check spelling and/or if the data needs to be re-collated"))
}

if(!(file.exists("./Projecting-Health/Area_population_df.csv"))){
  print("Area_population_df is not available, it will be built using the 'Areas_to_include' object")
  source(paste0(github_repo_dir,"/Get data - mye and projections.R"))
  
  if(file.exists("./Projecting-Health/Area_population_df.csv")){
    print("Area_population_df is now available.")
  }
}

if(exists("Areas_to_include") & file.exists("./Projecting-Health/Area_population_df.csv")){
  print("Both objects are available")
  Area_population_df <- read_csv("./Projecting-Health/Area_population_df.csv", col_types = cols(Area_Name = col_character(),Area_Code = col_character(),Area_Type = col_character(),  Sex = col_character(),Age_group = col_character(),Age_band_type = col_character(),Year = col_double(),Population = col_double(),Data_type = col_character())) %>% 
    group_by(Area_Name, Age_band_type, Year, Sex) %>% 
    mutate(All_age_population = sum(Population, na.rm = TRUE)) %>% 
    mutate(Proportion = Population / All_age_population) %>% 
    filter(Age_band_type == "5 years") %>% 
    mutate(Age_group  = factor(Age_group, levels = c("0-4 years","5-9 years","10-14 years","15-19 years","20-24 years","25-29 years","30-34 years","35-39 years","40-44 years","45-49 years","50-54 years","55-59 years","60-64 years","65-69 years","70-74 years","75-79 years","80-84 years","85-89 years","90+ years")))
  
  Areas <- read_csv("./Projecting-Health/Area_lookup_table.csv", col_types = cols(LTLA17CD = col_character(),LTLA17NM = col_character(),UTLA17CD = col_character(),UTLA17NM = col_character(),FID = col_double()))
  Lookup <- read_csv("./Projecting-Health/Area_types_table.csv", col_types = cols(Area_Code = col_character(),Area_Name = col_character(),Area_Type = col_character()))
  
  if(length(setdiff(Areas_to_include, Area_population_df$Area_Name))>0){
    print("There are some areas chosen that are not in the Area_population_df. The 'Get data - mye and projections' script will now run and will overwrite the Area_population_df.")
    source("~/Documents/Repositories/Projecting-Health/Get data - mye and projections.R")
  }
  
  if(length(setdiff(Areas_to_include, Area_population_df$Area_Name))>0){
    print("There are still some areas chosen that are not in the Area_population_df. Check the Areas_to_include object.")
  }
  
  if(length(setdiff(Areas_to_include, Area_population_df$Area_Name))==0){
    print("The Area_population_df matches the Areas_to_include list.")
  }
}

Years_available <- unique(Area_population_df$Year)

for(i in 1:length(Areas_to_include)){
Area_x <- Areas_to_include[i]

# We need to create a folder for each of our areas
if(!(file.exists(paste0("./Projecting-Health/Population_pyramid_image_files/",Area_x)))){
  dir.create(paste0("./Projecting-Health/Population_pyramid_image_files/",Area_x))
}

# if(!(file.exists(paste0("./Projecting-Health/Population_pyramid_image_files/",Area_x,"/Numbers")))){
#   dir.create(paste0("./Projecting-Health/Population_pyramid_image_files/",Area_x,"/Numbers"))
# }

if(!(file.exists(paste0("./Projecting-Health/Population_pyramid_image_files/",Area_x,"/Proportion")))){
  dir.create(paste0("./Projecting-Health/Population_pyramid_image_files/",Area_x,"/Proportion"))
}

Area_pyramid_df <- Area_population_df %>% 
  filter(Area_Name == Area_x)

# This looks across all years in the data to see what the maximum scale should be (so you can compare across years with a consistent scale)
pyramid_breaks_min <- 0 - ifelse(round_any(max(Area_pyramid_df$Population, na.rm = TRUE),50, f = ceiling) < 1000, round_any(max(Area_pyramid_df$Population, na.rm = TRUE), 100, f = ceiling), ifelse(round_any(max(Area_pyramid_df$Population, na.rm = TRUE),50, f = ceiling) < 2000, round_any(max(Area_pyramid_df$Population, na.rm = TRUE), 200, f = ceiling), ifelse(round_any(max(Area_pyramid_df$Population, na.rm = TRUE),50, f = ceiling) < 5000, round_any(max(Area_pyramid_df$Population, na.rm = TRUE),500, f = ceiling), ifelse(round_any(max(Area_pyramid_df$Population, na.rm = TRUE),50, f = ceiling) < 10000, round_any(max(Area_pyramid_df$Population, na.rm = TRUE),1000, f = ceiling), ifelse(round_any(max(Area_pyramid_df$Population, na.rm = TRUE),50, f = ceiling) < 15000, round_any(max(Area_pyramid_df$Population, na.rm = TRUE), 2500, f = ceiling), round_any(max(Area_pyramid_df$Population, na.rm = TRUE), 5000, f = ceiling))))))

pyramid_breaks_max <- ifelse(round_any(max(Area_pyramid_df$Population, na.rm = TRUE),50, f = ceiling) < 1000, round_any(max(Area_pyramid_df$Population, na.rm = TRUE), 100, f = ceiling), ifelse(round_any(max(Area_pyramid_df$Population, na.rm = TRUE),50, f = ceiling) < 2000, round_any(max(Area_pyramid_df$Population, na.rm = TRUE), 200, f = ceiling), ifelse(round_any(max(Area_pyramid_df$Population, na.rm = TRUE),50, f = ceiling) < 5000, round_any(max(Area_pyramid_df$Population, na.rm = TRUE),500, f = ceiling), ifelse(round_any(max(Area_pyramid_df$Population, na.rm = TRUE),50, f = ceiling) < 10000, round_any(max(Area_pyramid_df$Population, na.rm = TRUE),1000, f = ceiling),ifelse(round_any(max(Area_pyramid_df$Population, na.rm = TRUE),50, f = ceiling) < 15000, round_any(max(Area_pyramid_df$Population, na.rm = TRUE), 2500, f = ceiling), round_any(max(Area_pyramid_df$Population, na.rm = TRUE), 5000, f = ceiling))))))

pyramid_breaks_ticks <- ifelse(pyramid_breaks_max < 1000, 100, ifelse(pyramid_breaks_max < 2000, 200, ifelse(pyramid_breaks_max < 5000, 500, ifelse(pyramid_breaks_max < 10000, 1000, ifelse(pyramid_breaks_max < 15000, 2500, 5000)))))

x_value_for_year <- ifelse(pyramid_breaks_ticks == 100, pyramid_breaks_max - 100, ifelse(pyramid_breaks_ticks == 200, pyramid_breaks_max - 200, ifelse(pyramid_breaks_ticks == 500, pyramid_breaks_max - 250,  ifelse(pyramid_breaks_ticks == 1000, pyramid_breaks_max - 400,ifelse(pyramid_breaks_ticks == 15000, pyramid_breaks_max - 500, pyramid_breaks_max - 1000)))))

for(j in 1:length(Years_available)){
  Year_x <- Years_available[j]
  
  df_bars <- Area_pyramid_df %>% 
    filter(Year == Year_x)
  
df_lines <- Area_population_df %>% 
  ungroup() %>% 
  filter(Area_Name == "England") %>% 
  filter(Year == Year_x) %>% 
  rename(Comparator_number = Population,
         Comparator_proportion = Proportion,
         Comparator = Area_Name) %>% 
  select(Comparator, Age_group, Sex, Year, Comparator_number, Comparator_proportion)

combined_pyramid <- df_bars %>% 
  left_join(df_lines, by = c("Age_group", "Sex", "Year"))

# Pyramid_xabsolute_fig <- ggplot(data = combined_pyramid, aes(x = Age_group, y = Population, fill = Sex)) +
#   geom_bar(data = subset(combined_pyramid, Sex== "Female"),
#            stat = "identity") +
#   geom_bar(data = subset(combined_pyramid, Sex== "Male"),
#            stat = "identity",
#            position = "identity",
#            mapping = aes(y = -Population)) +
#   scale_fill_manual(values =  c("#ff6600", "#0099ff"), breaks = c("Males","Females")) +
#   coord_flip() +
#   pyramid_theme() + 
#   labs(title = paste0(Area_x),
#        caption = "Data source: Office for national statistics\nPopulation figures are rounded to the nearest 10.",
#        x = "",
#        y = "Population") +  
#   scale_y_continuous(breaks = seq(pyramid_breaks_min, pyramid_breaks_max, pyramid_breaks_ticks), limits = c(pyramid_breaks_min, pyramid_breaks_max), labels = abs_comma) + 
#   annotate("text", 
#            x = 19, 
#            y = pyramid_breaks_min, 
#            label = "Population aged 65+", 
#            size = 3, 
#            fontface = "bold", 
#            hjust = 0) +
#   annotate("text", 
#            x = 18.2, 
#            y = pyramid_breaks_min, 
#            label = format(round(sum(subset(combined_pyramid, Age_group %in% c("65-69 years", "70-74 years", "75-79 years", "80-84 years", "85-89 years", "90+ years"), select = "Population")),-1), big.mark = ","),
#            size = 7, 
#            col = "red", 
#            fontface = "bold", 
#            hjust = 0) +
#   annotate("text", y = pyramid_breaks_min, 
#            x = 16.85, 
#            label = paste0("This is ", round(sum(subset(combined_pyramid, Age_group %in% c("65-69 years", "70-74 years", "75-79 years", "80-84 years", "85-89 years", "90+ years"), select = "Population"))/sum(combined_pyramid$Population)*100,0), "% of the\ntotal population in\n", Year_x, " (",format(round(sum(combined_pyramid$Population),-1), big.mark = ","),")."), 
#            size = 3, 
#            hjust = 0) +
#   annotate("text", 
#            x = 19, 
#            y = x_value_for_year, 
#            label = Year_x, 
#            size = 7, 
#            fontface = "bold", 
#            hjust = 1) +
#   annotate("text", 
#            x = 19, 
#            y = pyramid_breaks_ticks*2, 
#            label = "Females", 
#            size = 3.5, 
#            fontface = "bold", 
#            hjust = 0) +
#   annotate("text", 
#            x = 19, 
#            y = -pyramid_breaks_ticks*2, 
#            label = "Males", 
#            size = 3.5, 
#            fontface = "bold", 
#            hjust = 1) 

Pyramid_xperc_fig <- ggplot(data = combined_pyramid, aes(x = Age_group, y = Proportion, fill = Sex)) +
    geom_bar(data = subset(combined_pyramid, Sex== "Female"),
             stat = "identity") +
    geom_line(data = subset(combined_pyramid, Sex== "Female"),
              aes(x = as.numeric(Age_group), 
                  y = Comparator_proportion), 
              colour="#4c4c4c", 
              size = .35) +
    geom_bar(data = subset(combined_pyramid, Sex== "Male"),
             stat = "identity",
             position = "identity",
             mapping = aes(y = -Proportion)) +
    geom_line(data = subset(combined_pyramid, Sex == "Male"), 
              aes(x = as.numeric(Age_group), y =-Comparator_proportion), 
              colour="#4c4c4c", 
              size = .3) + 
  scale_fill_manual(values =  c("#ff6600", "#0099ff"), 
                    breaks = c("Males","Females")) +
    coord_flip() +
    pyramid_theme() + 
    labs(title = paste0(Area_x),
         caption = "Data source: Office for national statistics\nPopulation figures are rounded to the nearest 10.",
         x = "",
         y = "Proportion") +  
    scale_y_continuous(breaks = seq(-.12, .12, .02), 
                       limits = c(-.12,.12), 
                       labels = abs_percent) + 
    annotate("text", 
             y = -.12, 
             x = 19, 
             label = "Population aged 65+", 
             size = 3, 
             fontface = "bold", 
             hjust = 0) +
    annotate("text", 
             y = -.12, 
             x = 18.2, 
             label = format(round(sum(subset(combined_pyramid, Age_group %in% c("65-69 years", "70-74 years", "75-79 years", "80-84 years", "85-89 years", "90+ years"), select = "Population")),-1), big.mark = ","), 
             size = 7, 
             col = "red", 
             fontface = "bold", 
             hjust = 0) +
    annotate("text", 
             x = 16.85, 
             y = -.12, 
             label = paste0("This is ", round(sum(subset(combined_pyramid, Age_group %in% c("65-69 years", "70-74 years", "75-79 years", "80-84 years", "85-89 years", "90+ years"), select = "Population"))/sum(combined_pyramid$Population)*100,0), "% of the\ntotal population in\n", Year_x, " (",format(round(sum(combined_pyramid$Population),-1), big.mark = ","),")."),
             size = 2.5, 
             hjust = 0) +
    annotate("text", 
           x = 19, 
           y = .09, 
           label = Year_x, 
           size = 7, 
           fontface = "bold", 
           hjust = 0) +
    annotate("text", 
             x = 19, 
             y = .05, 
             label = "Females", 
             size = 3.5, 
             fontface = "bold", 
             hjust = 0,
             vjust = 1) +
    annotate("text", 
             x = 19, 
             y = -.05, 
             label = "Males", 
             size = 3.5, 
             fontface = "bold", 
             hjust = 1,
             vjust = 1) +
  annotate("text", 
           x = 1.5, 
           y = .065, 
           label = paste0("Lines represent the\npopulation in ",Comparator_x), 
           size = 2.5, 
           fontface = "italic",
           hjust = 0)

# ggsave(paste0("./Projecting-Health/Population_pyramid_image_files/",Area_x,"/Numbers/Number_",Year_x,".png"), plot = Pyramid_xabsolute_fig, width = 7.5, height = 6, dpi = 250) 

ggsave(paste0("./Projecting-Health/Population_pyramid_image_files/",Area_x,"/Proportion/Proportion_",Year_x,".png"), plot = Pyramid_xperc_fig, width = 7.5, height = 6, dpi = 75) 

}
}

# Image processing ####

#install.packages('magick')
library(magick)

for(i in 1:length(Areas_to_include)){
  Area_x <- Areas_to_include[i]
list.files(path = paste0("./Projecting-Health/Population_pyramid_image_files/",Area_x,"/Proportion/"), pattern = "*.png", full.names = T) %>% 
  map(image_read) %>% # reads each path file
  image_join() %>% # joins image
  image_animate(fps=2) %>% # animates, can opt for number of loops
  image_write(paste0("./Projecting-Health/Population_pyramid_image_files/",Area_x,"_2011_41.gif"),
              quality = 50,
              density = 100) # write to current dir
}
