# PPHA 30536 1 - Data and Programming for Public Policy II - R Programming 
# Data Skills 2 - R
## Fall Quarter 2024
# Date: 11.30.24
# Student: Natalia Zorrilla
# Final Project - OLS Model
## Due: December 7, 2024 before midnight on Gradescope
############################################################################################################

#IN THIS PART OF THE PROJECT WE'LL PERFORM AN OLS ANALYSIS ON NARCOTICS CRIMES, MENTAL HEALTH RESOURCES AND SOCIOECONOMIC INDICATORS

#install.packages(c("tidyverse", "stargazer", "car"))

library(tidyverse) 
library(stargazer)  
library(car)       

#Clear all objects
rm(list=ls())

#To replicate this project, please set your working directory in this initial stage. 
setwd("/Users/Natalia/Documents/The University of Chicago/Harris School of Public Policy/MPP/Fall quarter 2024/PPHA 30536 1 - Data and Programming for Public Policy II - R Programming /Assignments/Final project")

#Import data. If you don't have it, please run first data.R file
narcotics_health_project_data <- read_csv("narcotics_health_project_data.csv")

#We are going to perform three different OLS regressions adjusting the independent variables

#Narcotics and total providers
model_1 <- lm(narcotics_crime_rate ~ total_providers, data = narcotics_health_project_data) 
#Table 1 with results 
stargazer(model_1, type = "text", title = "Regression Results for Narcotics Crime Rate Model 1", 
          notes = "Standard errors in parentheses")

#Narcotics, total providers and crisis providers
model_2 <- lm(narcotics_crime_rate ~ total_providers + crisis_providers + Population, data = narcotics_health_project_data)

#Check for multicollinearity using VIF
vif(model_2)

#Table 2 with results 
stargazer(model_2, type = "text", title = "Regression Results for Narcotics Crime Rate Model 2", 
          notes = "Standard errors in parentheses")

#Narcotics, total providers, crisis providers and socioeconomic indicators
model_3 <- lm(narcotics_crime_rate ~ 
                total_providers + 
                crisis_providers + 
                Population + 
                Neighborhood_Safety_Rate + 
                Trust_Law_Enforcement_Rate + 
                Trust_Local_Government_Rate + 
                Unemployment_Rate + 
                Median_Household_Income,
              data = narcotics_health_project_data)

#Table 3 with results 
stargazer(model_3, type = "text", 
          title = "OLS Regression Results for Narcotics Crime Rate Model 3", 
          notes = "Standard errors in parentheses")

#Check for multicollinearity using VIF
vif(model_3)
