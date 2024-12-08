#FINAL PROJECT PART 2 - STATIC PLOT FILES
# PPHA 30536 1 - Data and Programming for Public Policy II - R Programming 
# Data Skills 2 - R
## Fall Quarter 2024
# Date: 11.30.24
# Student: Natalia Zorrilla
# Final Project - Static Plots
## Due: December 7, 2024 before midnight on Gradescope
############################################################################################################
#THIS PART OF THE PROJECT WILL SERVE TO VISUALIZE DIFFERENT ASPECTS OF CRIME, NARCOTICS CRIMES, MENTAL HEALTH RESOURCES AND SOCIOECONOMIC INDICATORS

library(dplyr)
library(ggplot2)
library(readr)
library(scales)
library(RColorBrewer)
library(viridis)
library(sf)

#All plots in this script will be automatically saved in the current working directory. 
#To replicate this project, please set your working directory in this initial stage. 
setwd("/Users/Natalia/Documents/The University of Chicago/Harris School of Public Policy/MPP/Fall quarter 2024/PPHA 30536 1 - Data and Programming for Public Policy II - R Programming /Assignments/Final project")


#Clear all objects
rm(list=ls())

#The following data sets will be needed 
narcotics_health_project_data <- read_csv("narcotics_health_project_data.csv")
chicago_crime_sf <- read_csv("chicago_crime_sf.csv")
narc_sf <- readRDS("narcotics_spatial_data.rds")
crisis_sf <- readRDS("mental_health_spatial_data.rds")

##### STATIC PLOT 1 - TYPE OF CRIMES
# Group by crime type and count incidents 
#Note: This was done as well in the cleaning process but it's replicated to create a plot
crime_by_type <- chicago_crime_sf %>%
  group_by(`Primary Type`) %>%
  summarize(Count = n(), .groups = "drop") %>%
  arrange(desc(Count)) %>%
  slice_max(Count, n = 10)

#Bar plot showing top 10 crime types
ggplot(crime_by_type, aes(x = reorder(`Primary Type`, Count), y = Count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Crime Types in Chicago (2018-2022)",
    x = "Crime Type",
    y = "Number of Incidents",
    caption = "Source: City of Chicago Data Portal"
  ) +
  scale_y_continuous(labels = comma, breaks = seq(0, 250000, 50000)) +
  theme_minimal() +
  theme(
    plot.caption = element_text(hjust = 1, size = 10, face = "italic"),  # Style caption
    plot.title = element_text(size = 16, face = "bold")
  )

#save plot
ggsave("top_ten_crimes_barplot.png")

##### STATIC PLOT 2 - NARCOTICS AND SOCIOECONOMIC FACTORS 
#Bar Plot
ggplot(narcotics_health_project_data, aes(x = Income_Bracket, y = total_crimes, fill = Income_Bracket)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Narcotics Crime Rates in Chicago by Income",
    subtitle = "Binned Income Levels (2018-2022)",
    x = "Median Household Income Bracket",
    y = "Narcotics Crime Count",
    caption = "Sources: Chicago Data Portal (Crime), Chicago Health Atlas (Socioeconomic Indicators)"
  ) +
  scale_fill_brewer(palette = "Blues") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.caption = element_text(hjust = 1),
    legend.position = "none" 
  )

ggsave("narcotics_crimes_by_income.png", width = 8, height = 6)

##### STATIC PLOT 3 - NARCOTICS AND LAW ENFORCEMENT
#Bar Plot
ggplot(narcotics_health_project_data, aes(x = Trust_Law_Enforcement_Bins, y = total_crimes, fill = Trust_Law_Enforcement_Bins)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Narcotics Crime Rates in Chicago by Trust in Law Enforcement",
    subtitle = "Binned Trust Rates Levels (2018-2022)",
    x = "Trust in Law Enforcement (%)",
    y = "Total Narcotics Crimes",
    fill = "Trust Bin",
    caption = "Sources: Chicago Data Portal (Crime), Chicago Health Atlas (Socioeconomic Indicators)"
  ) +
  scale_fill_brewer(palette = "Blues") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.caption = element_text(hjust = 1),
    legend.position = "none" 
  ) 
ggsave("narcotics_crimes_by_trust_in_law.png", width = 8, height = 6)

##### STATIC PLOT 4 - NARCOTICS AND UNEMPLOYMENT
#Bar Plot
ggplot(narcotics_health_project_data, aes(x = Unemployment_Rate_Bins, y = total_crimes, fill = Unemployment_Rate_Bins)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Narcotics Crime Rates in Chicago by Unemployment Rate",
    subtitle = "Binned Unemployment Rates (2018-2022)",
    x = "Unemployment Rate (%)",
    y = "Total Narcotics Crimes",
    caption = "Sources: Chicago Data Portal (Crime), Chicago Health Atlas (Socioeconomic Indicators)"
  ) +
  scale_fill_brewer(palette = "Blues") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.caption = element_text(hjust = 1),
    legend.position = "none"
  )
ggsave("narcotics_crimes_by_unemployment.png", width = 8, height = 6)

##### STATIC PLOT 5 - NARCOTICS AND NEIGHBORHOOD SAFETY
#Bar Plot
ggplot(narcotics_health_project_data, aes(x = Safety_Rate_Bins, y = total_crimes, fill = Safety_Rate_Bins)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Narcotics Crime Rates by Neighborhood Safety Rate",
    subtitle = "Binned Safety Rate Levels (2018-2022)",
    x = "Neighborhood Safety Rate (%)",
    y = "Total Narcotics Crimes",
    caption = "Sources: Chicago Data Portal (Crime), Chicago Health Atlas (Socioeconomic Indicators)"
  ) +
  scale_fill_brewer(palette = "Reds") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.caption = element_text(hjust = 1),
    legend.position = "none"
  ) 
ggsave("narcotics_crimes_by_safety.png", width = 8, height = 6)

##### STATIC PLOT 6 - NARCOTICS CRIMES
#Note: Spatial plot to understand the geographic distribution of narcotics related crimes across Chicago
#Heat map
ggplot() +
  geom_sf(data = narc_sf, aes(fill = total_crimes)) +
  scale_fill_viridis_c(option = "viridis", 
                       na.value = "gray80",
                       name = "Total Crimes") +
  labs(title = "Total Narcotic related crimes in Chicago by Neighborhood",
       caption = "Sources: Chicago Data Portal (Crime)") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14),
    axis.text = element_text(size = 8),
    plot.caption = element_text(hjust = 1)
  )

ggsave("narcotics_crimes_heatmap.png", width = 8, height = 6)

##### STATIC PLOT 7 - MENTAL HEALTH RESOURCES HEATMAP
#Note: Spatial plot to understand the geographic distribution of health clinics across Chicago
#Heat map
ggplot() +
  geom_sf(data = crisis_sf, aes(fill = total_providers)) +
  scale_fill_viridis_c(option = "viridis", 
                       na.value = "gray80",
                       name = "Total Mental Health Providers",
                       labels = scales::label_number(accuracy = 1)) +
  labs(title = "Total Mental Health Providers in Chicago by Neighborhood",
       caption = "Source: Chicago Mental Health Resources Data") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14),
    axis.text = element_text(size = 8),
    plot.caption = element_text(hjust = 1)
  )

ggsave("mental_health_resources_heatmap.png", width = 8, height = 6)

##### STATIC PLOT 8 - CRISIS PROVIDERS HEATMAP 
#Note: Spatial plot to understand the geographic distribution of crisis providers across Chicago
#Heat map
ggplot() +
  geom_sf(data = crisis_sf, aes(fill = crisis_providers)) +
  scale_fill_viridis_c(option = "viridis", 
                       na.value = "gray80",
                       name = "Total Crisis Providers") +
  labs(title = "Total Mental Health Crisis Providers in Chicago by Neighborhood",
       caption = "Source: Chicago Mental Health Resources Data") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14),
    axis.text = element_text(size = 8),
    plot.caption = element_text(hjust = 1)
  )

ggsave("crisis_providers_heatmap.png", width = 8, height = 6)
