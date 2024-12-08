# PPHA 30536 1 - Data and Programming for Public Policy II - R Programming 
# Data Skills 2 - R
## Fall Quarter 2024
# Date: 11.30.24
# Student: Natalia Zorrilla
# Final Project - Data
## Due: December 7, 2024 before midnight on Gradescope
############################################################################################################

#IN THIS FIRST PART OF THE PROJECT WE'LL DOWNLOAD RAW DATA, SAVE IT AND CLEAN IT FOR THE NEXT PARTS OF THE PROJECT

#Research Question: How do access to mental health resources and socioeconomic factors influence crime rates in Chicago’s neighborhoods? 

#install.packages(c("dplyr", "readr", "stringr", "sf", "httr"))

library(dplyr)
library(readr)
library(stringr)
library(sf)
library(httr)

# clear all objects
rm(list=ls())

#All files in this script will be automatically downloaded in the current working directory. 
#To replicate this project, please set your working directory in this initial stage. 
setwd("/Users/Natalia/Documents/The University of Chicago/Harris School of Public Policy/MPP/Fall quarter 2024/PPHA 30536 1 - Data and Programming for Public Policy II - R Programming /Assignments/Final Project")
#import data sets that were downloaded to my computer
crime <- read_csv("Crimes_-_2001_to_Present_20241130.csv")
chicago_atlas <- read_csv("Chicago Health Atlas Data Download - Community areas.csv")
zippath <- "/Users/Natalia/Documents/The University of Chicago/Harris School of Public Policy/MPP/Fall quarter 2024/PPHA 30536 1 - Data and Programming for Public Policy II - R Programming /Assignments/Final Project/Boundaries - Neighborhoods"
chicago_shape <- st_read(file.path(zippath, "geo_export_1b144f37-7203-4949-a2b7-caf7af432f62.shp"))

#import mental health using an API endpoint (authorized by Professor Shi)
url <- "https://data.cityofchicago.org/resource/wust-ytyg.csv"
#download and read the CSV file directly
response <- GET(url)
mental_health_data <- content(response, as = "text", encoding = "UTF-8")
mental_health_resources <- read_csv(mental_health_data)

#These steps are optional if the user wants to have an overview of the raw data.
#glimpse(crime)
#glimpse(chicago_atlas)
#glimpse(mental_health_resources)
#glimpse(chicago_atlas)

##############################################################################################################################
#LET'S START WORKING WITH CRIME IN CHICAGO
#df used: crime
#glimpse(crime)

#Start cleaning data
crime$Date <- as.POSIXct(crime$Date, format = "%m/%d/%Y %I:%M:%S %p")
crime$Date <- as.Date(crime$Date)
# Filter crime data from 2018 to 2022
crime_filtered <- crime %>%
  filter(Year >= 2018 & Year < 2023) %>% 
  #get rid of NAs
  filter(!is.na(Latitude) & !is.na(Longitude)) 
# Check the result if needed
#glimpse(crime_filtered)

#Top 10 crime types
#Group by crime type and count incidents
crime_by_type <- crime %>%
  group_by(`Primary Type`) %>%
  summarize(Count = n(), .groups = "drop") %>%
  arrange(desc(Count)) %>%
  slice_max(Count, n = 10) 

#Since the research question is the relationship between crime and access to mental health resources, I decided to narrow the type of crime to narcotics.
#The user can decide to explore the relationship with other type of crimes by changing the "Primary Type` == [Type of crime]" variable.
#Narcotics dataset
narcotics_crime <- crime_filtered  %>%  
  filter(`Primary Type` == "NARCOTICS")

#Verify spacial data since it will be used for plotting in a second phase of the project.
#Check CRS
#st_crs(chicago_shape) == st_crs(crime_sf) if TRUE, skip next steps, if FALSE, continue running the code.

#convert crime_filtered to sf
crime_sf <- st_as_sf(crime_filtered, coords = c("Longitude", "Latitude"), crs = 4326)
#transform crs so both df can match
chicago_shape <- st_transform(chicago_shape, 4326)
#join crime and chicago sf
chicago_crime_sf <- st_join(crime_sf, chicago_shape, join = st_within)
#Save cleaned data as CSV file - Will be needed for visualization part
write_csv(chicago_crime_sf, "chicago_crime_sf.csv")
#convert narcotics_crime to sf
narcotics_sf <- st_as_sf(narcotics_crime, coords = c("Longitude", "Latitude"), crs = 4326)
#join narcotics_crime and chicago shape
chicago_narcotics_sf <- st_join(narcotics_sf, chicago_shape, join = st_within)
#save as shape file - needed for shiny app
saveRDS(chicago_narcotics_sf, "chicago_narcotics_sf.rds")

#Group and summarize the filtered crime data by Community Area
crime_summary <- chicago_crime_sf %>%
  group_by(`pri_neigh`, `Primary Type`) %>%
  summarise(
    total_crimes = n(), 
    total_arrests = sum(Arrest, na.rm = TRUE),
    .groups = "drop"
  )

#Group and summarize the filtered narcotics data by Community Area
narcotics_summary <- chicago_narcotics_sf %>%
  group_by(`pri_neigh`) %>%
  summarise(
    total_crimes = n(), 
    total_arrests = sum(Arrest, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  ungroup()

#Join narcotics summary with spatial data using st_join
narc_sf <- st_join(chicago_shape, 
                   narcotics_summary,
                   join = st_intersects,
                   left = TRUE)

#Save the spatial data frame as an RDS file - - Will be needed for visualization part
saveRDS(narc_sf, "narcotics_spatial_data.rds")

############################################################################################################
#NOW LET'S WORK WITH MENTAL HEALTH RESOURCES IN CHICAGO
#df used: mental_health_resources (extracted using API)
#glimpse(mental_health_resources)

#Convert location string to spatial points
mh_sf <- mental_health_resources %>%
  st_as_sf(wkt = "location", crs = 4326) %>%
  filter(!is.na(st_geometry(.)))

#count crisis services by neighborhood using spatial join with chicago_shape
crisis_by_neighborhood <- mh_sf %>%
  st_join(chicago_shape) %>%
  group_by(pri_neigh) %>%
  summarise(
    total_providers = n(),
    crisis_providers = sum(crisis_services, na.rm = TRUE)
  ) %>%
  arrange(desc(crisis_providers)) %>%
  ungroup()

#Join with spatial data using st_join
crisis_sf <- st_join(chicago_shape, 
                     crisis_by_neighborhood,
                     join = st_intersects,
                     left = TRUE)

crisis_sf <- crisis_sf %>%
  mutate(
    pri_neigh = coalesce(pri_neigh.x, pri_neigh.y)
  ) %>%
  select(
    pri_neigh, sec_neigh, shape_area, shape_len, total_providers, crisis_providers, geometry
  )

#Save the spatial data frame as an RDS file - - Will be needed for visualization part
saveRDS(crisis_sf, "mental_health_spatial_data.rds")

############################################################################################################
#NOW LET'S WORK WITH SOCIOECONOMIC INDICATORS IN CHICAGO
#df used: chicago_atlas 
#glimpse(chicago_atlas)
#rename columns in the dataframe
chicago_atlas <- chicago_atlas %>%
  rename(
    Category = Layer,
    Community_Area_Name = Name,
    `Community Area` = GEOID,
    Population = Population,
    Longitude = Longitude,
    Latitude = Latitude,
    Neighborhood_Safety_Count = `HCSNS_2022-2023`,
    Neighborhood_Safety_Rate = `HCSNSP_2022-2023`,
    Trust_Law_Enforcement_Count = `HCSTLE_2022-2023`,
    Trust_Law_Enforcement_Rate = `HCSTLEP_2022-2023`,
    Trust_Local_Government_Count = `HCSTLG_2022-2023`,
    Trust_Local_Government_Rate = `HCSTLGP_2022-2023`,
    Unemployment_Rate = `UMP_2018-2022`,
    Median_Household_Income = `INC_2018-2022`,
    Poverty_Rate = `POV_2018-2022`
  )
#remove the first row from the dataframe (it provides an explanation of each indicator)
chicago_atlas <- chicago_atlas[-1, ]

#verify the changes
#glimpse(chicago_atlas)

#Join the crime data with the atlas data based on Community Area
chicago_crime_indicators_sf <- chicago_crime_sf %>%
  left_join(chicago_atlas, by = "Community Area")

#glimpse(chicago_crime_indicators_sf)

#Join the narcotics data with the atlas data based on Community Area
chicago_narcotics_indicators_sf <- chicago_narcotics_sf %>%
  left_join(chicago_atlas, by = "Community Area")

############################################################################################################
#NOW LET'S CREATE A FINAL CLEANING DATA FOR CRIME, MENTAL HEALTH AND SOCIOECONOMIC FACTORS IN CHICAGO
#Final merged data
merged_data <- st_join(chicago_narcotics_indicators_sf, crisis_sf, join = st_intersects)
#delete duplicated columns
merged_data <- merged_data %>%
  mutate(
    pri_neigh = coalesce(pri_neigh.x, pri_neigh.y),
    sec_neigh = coalesce(sec_neigh.x, sec_neigh.y),
    shape_area = coalesce(shape_area.x, shape_area.y),
    shape_len = coalesce(shape_len.x, shape_len.y)
  ) %>%
  select(
    -ends_with(".x"),
    -ends_with(".y")
  )

#verify the changes
#glimpse(merged_data_clean)

narcotics_health_project_data <- merged_data %>%
  group_by(pri_neigh) %>%
  summarise(
    total_crimes = n(),  #count the total number of crimes (rows)
    total_arrests = sum(Arrest, na.rm = TRUE),  #sum the 'Arrest' column, ignoring NAs
    total_providers = first(total_providers),
    crisis_providers = first(crisis_providers),
    `Community Area` = first(`Community Area`),
    Population = first(Population),
    Neighborhood_Safety_Rate = first(Neighborhood_Safety_Rate),
    Trust_Law_Enforcement_Rate = first(Trust_Law_Enforcement_Rate),
    Trust_Local_Government_Rate = first(Trust_Local_Government_Rate),
    Unemployment_Rate = first(Unemployment_Rate),
    Median_Household_Income = first(Median_Household_Income),
    .groups = "drop"
  ) %>%
  ungroup()


#Convert character columns to numeric
narcotics_health_project_data <- narcotics_health_project_data %>%
  mutate(
    Neighborhood_Safety_Rate = as.numeric(Neighborhood_Safety_Rate),
    Trust_Law_Enforcement_Rate = as.numeric(Trust_Law_Enforcement_Rate),
    Trust_Local_Government_Rate = as.numeric(Trust_Local_Government_Rate),
    Unemployment_Rate = as.numeric(Unemployment_Rate),
    Median_Household_Income = as.numeric(Median_Household_Income)
  )

#Calculate Narcotics Crime Rate per 1,000 residents
narcotics_health_project_data <- narcotics_health_project_data %>%
  mutate(narcotics_crime_rate = (total_crimes / Population) * 1000)

#Create median household income bins
narcotics_health_project_data <- narcotics_health_project_data %>%
  filter(total_crimes > 0) %>% 
  mutate(Income_Bracket = cut(Median_Household_Income, 
                              breaks = c(0, 40000, 60000, 80000, 100000, Inf), 
                              labels = c("<40k", "40k-60k", "60k-80k", "80k-100k", ">100k")))

#Create Trust in Law Enforcement bins
narcotics_health_project_data$Trust_Law_Enforcement_Bins <- cut(
  narcotics_health_project_data$Trust_Law_Enforcement_Rate,
  breaks = seq(0, 100, by = 10),
  labels = c("0-10%", "10-20%", "20-30%", "30-40%", "40-50%", "50-60%", "60-70%", "70-80%", "80-90%", "90-100%"),
  include.lowest = TRUE
)
#Create Unemployment Rate bins (as a percentage)
narcotics_health_project_data$Unemployment_Rate_Bins <- cut(narcotics_health_project_data$Unemployment_Rate, 
                                                            breaks = seq(0, 35, by = 5), 
                                                            include.lowest = TRUE, 
                                                            labels = c("0-5%", "5-10%", "10-15%", "15-20%", "20-25%", "25-30%", "30-35%"))

#Create Neighborhood Safety Rate bins
narcotics_health_project_data$Safety_Rate_Bins <- cut(narcotics_health_project_data$Neighborhood_Safety_Rate, 
                                                      breaks = seq(20, 100, by = 10), 
                                                      include.lowest = TRUE, 
                                                      labels = c("20-30%", "30-40%", "40-50%", "50-60%", "60-70%", "70-80%", "80-90%", "90-100%"))

#Join with chicago_shape
narcotics_health_project_data <- st_join(narcotics_health_project_data, chicago_shape, join = st_intersects)

#Final cleaning (remove duplicate columns, NAs and convert to factor)
narcotics_health_project_data <- narcotics_health_project_data %>%
  select(
    pri_neigh = pri_neigh.x,
    total_crimes,
    total_arrests,
    total_providers,
    crisis_providers,
    `Community Area`,
    Population,
    Neighborhood_Safety_Rate,
    Trust_Law_Enforcement_Rate,
    Trust_Local_Government_Rate,
    Unemployment_Rate,
    Median_Household_Income,
    narcotics_crime_rate,
    Income_Bracket,
    Trust_Law_Enforcement_Bins,
    Unemployment_Rate_Bins,
    Safety_Rate_Bins,
    sec_neigh,
    shape_area,
    shape_len,
    geometry
  ) %>%
  filter(!is.na(total_arrests) & !is.na(total_crimes)) %>%
  mutate(
    Income_Bracket = factor(Income_Bracket),
    Trust_Law_Enforcement_Bins = factor(Trust_Law_Enforcement_Bins),
    Unemployment_Rate_Bins = factor(Unemployment_Rate_Bins),
    Safety_Rate_Bins = factor(Safety_Rate_Bins)
  )


#verify the changes
#glimpse(narcotics_health_project_data)

#Save cleaned data as CSV file
write_csv(narcotics_health_project_data, "narcotics_health_project_data.csv")

#Save cleaned data as CSV file - needed for shiny app 2
#Crime filtered variable
crime_filtered <- crime_filtered %>%
  group_by(`Community Area`, `Primary Type`) %>%
  summarise(total_crimes = n(), .groups = 'drop')
#convert type of crime to sentence case (lowercase except first letter)
crime_filtered$`Primary Type` <- str_to_lower(crime_filtered$`Primary Type`)  
crime_filtered$`Primary Type` <- str_to_title(crime_filtered$`Primary Type`)
write_csv(crime_filtered, "crime_2018_2022.csv")


##############################################################################################################################
#Option to use archived version of retrieved dataset
#Prompt user for data source
use_archived_data <- readline("Use archived dataset? (yes/no): ")

#Define file paths
archived_file <- "mental_health_data_archived.csv"
api_url <- "https://data.cityofchicago.org/resource/wust-ytyg.csv"

#Load data based on user input
if (tolower(use_archived_data) == "yes" && file.exists(archived_file)) {
  message("Loading archived dataset...")
  mental_health_resources <- read_csv(archived_file)
} else {
  message("Retrieving dataset from API...")
  response <- GET(api_url)
  mental_health_data <- content(response, as = "text", encoding = "UTF-8")
  mental_health_resources <- read_csv(mental_health_data)
  
  #Save the retrieved data as an archive
  write_csv(mental_health_resources, archived_file)
  message("Data retrieved and archived.")
}

## Check the result if needed
#glimpse(mental_health_resources)
