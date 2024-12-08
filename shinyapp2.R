# PPHA 30536 1 - Data and Programming for Public Policy II - R Programming 
# Data Skills 2 - R
## Fall Quarter 2024
# Date: 12.07.24
# Student: Natalia Zorrilla
# Final Project - Shiny App 2
## Due: December 7, 2024 before midnight on Gradescope
############################################################################################################

#IN THIS PART OF THE PROJECT WE'LL CREATE A SHINY APP TO EXPLORE THE RELATIONSHIP BETWEEN CRIME AND SOCIOECONOMIC FACTORS IN CHICAGO FOR 2018 TO 2022

#install.packages(c("shiny", "sf", "dplyr", "ggplot2", "scales", "tidyverse"))

library(shiny)
library(dplyr)
library(ggplot2)
library(sf)
library(tidyverse)

#Clear all objects
rm(list=ls())

#Set the working directory where the files: crime_2018_2022.csv and narcotics_health_project_data.csv are located.
#Note: If you don't have the files, please run data.R file first.

setwd("/Users/Natalia/Documents/The University of Chicago/Harris School of Public Policy/MPP/Fall quarter 2024/PPHA 30536 1 - Data and Programming for Public Policy II - R Programming /Assignments/Final project")

#Load Data
crime_filtered <- read_csv("crime_2018_2022.csv")
socioeconomic_data <- read_csv("narcotics_health_project_data.csv")

#Erase the total_crimes since it only refers to narcotics and the objective of this app is to show all crimes
socioeconomic_data <- socioeconomic_data %>% 
  select(- "total_crimes")

#UI
ui <- fluidPage(
  titlePanel("Crime and Socioeconomic Data Correlation in Chicago"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("This app allows you to explore the relationship between different types of crimes 
                reported in Chicago and various socioeconomic indicators from 2018 to 2022."),
      selectInput("crime_type", "Select Crime Type:",
                  choices = unique(crime_filtered$`Primary Type`)),
      selectInput("socio_indicator", "Select Socioeconomic Indicator:",
                  choices = c("Median Household Income", "Unemployment Rate", 
                              "Neighborhood Safety Rate",
                              "Trust in Law Enforcement Rate", 
                              "Trust in Local Government Rate")),
      helpText("Choose a crime type and a socioeconomic indicator to see the correlation.")
    ),
    
    mainPanel(
      h3("Results Overview"),
      plotOutput("correlation_plot"),
      verbatimTextOutput("summary_output")
    )
  )
)


#Server
server <- function(input, output, session) {
  
  #Join the two data frames Community Area
  joined_data <- reactive({
    crime_data <- crime_filtered %>%
      filter(`Primary Type` == input$crime_type)
    
    joined <- left_join(crime_data, socioeconomic_data, by = "Community Area")
    return(joined)
  })
  
  #Correlation Plot
  output$correlation_plot <- renderPlot({
    data <- joined_data()
    
    #Select socioeconomic indicator for y-axis
    y_var <- switch(input$socio_indicator,
                    "Median Household Income" = data$Median_Household_Income,
                    "Unemployment Rate" = data$Unemployment_Rate,
                    "Neighborhood Safety Rate" = data$Neighborhood_Safety_Rate,
                    "Trust in Law Enforcement Rate" = data$Trust_Law_Enforcement_Rate,
                    "Trust in Local Government Rate" = data$Trust_Local_Government_Rate)
    
    ggplot(data, aes(x = total_crimes, y = y_var)) +
      geom_point(alpha = 0.6, color = "blue") +
      geom_smooth(method = "lm", color = "red", se = FALSE) +
      labs(
        title = paste("Correlation between", input$crime_type, "and", input$socio_indicator),
        x = "Total Crimes",
        y = input$socio_indicator
      ) +
      theme_minimal()
  })
  
  #Display Summary Stats of the Joined Data
  output$summary_output <- renderPrint({
    summary(joined_data())
  })
}

#Test the app
shinyApp(ui = ui, server = server)
