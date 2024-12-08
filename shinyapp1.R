# PPHA 30536 1 - Data and Programming for Public Policy II - R Programming 
# Data Skills 2 - R
## Fall Quarter 2024
# Date: 12.07.24
# Student: Natalia Zorrilla
# Final Project - Shiny App 1
## Due: December 7, 2024 before midnight on Gradescope
############################################################################################################

#IN THIS PART OF THE PROJECT WE'LL CREATE A SHINY APP TO EXPLORE THE RELATIONSHIP BETWEEN CRIME AND MENTAL HEALTH PROVIDERS

#install.packages(c("shiny", "sf", "dplyr", "ggplot2", "scales"))

# Load Libraries
library(shiny)
library(sf)
library(dplyr)
library(ggplot2)
library(scales)

#Clear all objects
rm(list=ls())

#Adjust the working directory as needed
setwd("/Users/Natalia/Documents/The University of Chicago/Harris School of Public Policy/MPP/Fall quarter 2024/PPHA 30536 1 - Data and Programming for Public Policy II - R Programming /Assignments/Final Project")

#Set the working directory where the files: chicago_narcotics_sf.rds and mental_health_resources.rds are located.
#Note: If you don't have the files, please run data.R file first.

#Load Data
zippath <- "/Users/Natalia/Documents/The University of Chicago/Harris School of Public Policy/MPP/Fall quarter 2024/PPHA 30536 1 - Data and Programming for Public Policy II - R Programming /Assignments/Final project/Boundaries - Neighborhoods"
chicago_shape <- st_read(file.path(zippath, "geo_export_1b144f37-7203-4949-a2b7-caf7af432f62.shp"))
chicago_narcotics_sf <- readRDS("chicago_narcotics_sf.rds")
mh_sf <- readRDS("mental_health_resources.rds")

# Ensure consistent CRS for all spatial data
chicago_shape <- st_transform(chicago_shape, 4326)
chicago_narcotics_sf <- st_transform(chicago_narcotics_sf, 4326)
mh_sf <- st_transform(mh_sf, 4326)

# Ensure CRS Compatibility
if (st_crs(chicago_shape) != st_crs(chicago_narcotics_sf)) {
  chicago_narcotics_sf <- st_transform(chicago_narcotics_sf, st_crs(chicago_shape))
}

#Data Validity Check
if (!exists("chicago_shape") || !exists("chicago_narcotics_sf") || !exists("mh_sf")) {
  stop("One or more required datasets could not be loaded. Check file paths.")
}

#Shiny App
#UI
ui <- fluidPage(
  titlePanel("Narcotics-Related Crime and Mental Health Resources in Chicago"),
  
  fluidRow(
    column(12,
           wellPanel(
             p("This app visualizes narcotics-related crime data and mental health resources across Chicago neighborhoods.")
           )
    )
  ),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("location", "Select Neighborhood:", 
                  choices = c("All Chicago", sort(unique(chicago_shape$pri_neigh)))),
      selectInput("display_type", "Display Options:", 
                  choices = c(
                    "Narcotics Arrest Heatmap" = "heatmap",
                    "Heatmap with All Resources" = "all_resources",
                    "Heatmap with Crisis Services" = "crisis_services"
                  )),
      actionButton("reset", "Reset to Default"),
      helpText("Choose a neighborhood and display type to explore data.")
    ),
    mainPanel(
      plotOutput("map_plot", height = "600px")
    )
  )
)

#Server
server <- function(input, output, session) {
  
  # Reactive: Narcotics Data
  narcotics_data <- reactive({
    req(chicago_narcotics_sf)
    chicago_narcotics_sf %>%
      group_by(pri_neigh) %>%
      summarise(
        total_crimes = n(), 
        total_arrests = sum(Arrest, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      ungroup()
  })
  
  # Reactive: Spatial Data for Map
  spatial_data <- reactive({
    req(input$location)
    
    base_data <- if (input$location == "All Chicago") {
      chicago_shape
    } else {
      chicago_shape %>% filter(pri_neigh == input$location)
    }
    
    result <- st_join(base_data, narcotics_data(), join = st_intersects, left = TRUE)
    if (nrow(result) == 0) {
      showNotification("No narcotics data found in the selected area.", type = "warning")
    }
    result
  })
  
  # Reactive: Mental Health Data
  mh_filtered <- reactive({
    req(input$display_type != "heatmap", mh_sf)
    
    chicago_boundary <- if (input$location == "All Chicago") {
      st_union(chicago_shape)
    } else {
      chicago_shape %>% filter(pri_neigh == input$location) %>% st_union()
    }
    
    filtered_data <- switch(input$display_type,
                            "crisis_services" = mh_sf %>% filter(crisis_services == TRUE),
                            "all_resources" = mh_sf,
                            mh_sf)
    
    result <- st_intersection(filtered_data, chicago_boundary)
    if (nrow(result) == 0) {
      showNotification("No mental health resources found in the selected area.", type = "warning")
    }
    result
  })
  
  
  # Map Rendering
  output$map_plot <- renderPlot({
    req(spatial_data())
    
    tryCatch({
      base_plot <- ggplot() +
        geom_sf(data = spatial_data(), aes(fill = total_arrests), 
                color = "white", size = 0.2, na.rm = TRUE) +
        scale_fill_viridis_c(option = "viridis", 
                             na.value = "gray80",
                             name = "Total Narcotics Arrests",
                             labels = scales::comma) +
        coord_sf() +
        theme_minimal() +
        labs(
          title = paste("Narcotics-Related Arrests in", input$location),
          caption = "Data source: Chicago Police Department"
        ) +
        theme(
          plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
          axis.text = element_text(size = 8),
          legend.position = "bottom",
          legend.key.width = unit(1, "cm")
        )
      
      # Add Mental Health Data if Required
      if (input$display_type != "heatmap" && !is.null(mh_filtered()) && nrow(mh_filtered()) > 0) {
        base_plot <- base_plot + 
          geom_sf(data = mh_filtered(), 
                  color = "lightblue", 
                  size = 3, 
                  shape = 17, 
                  alpha = 0.8) +
          labs(caption = paste(base_plot$labels$caption, "| Mental Health Resources: City of Chicago"))
      }
      
      base_plot
      
    }, error = function(e) {
      plot.new()
      text(0.5, 0.5, paste("Error: Unable to render map.\n", e$message), 
           cex = 1.2, col = "red")
    })
  })
}


# Run the app
shinyApp(ui = ui, server = server)
