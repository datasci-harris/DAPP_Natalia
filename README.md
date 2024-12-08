Natalia Zorrilla
Final Project: Data Analysis on Crime, Mental Health, and Socioeconomic Indicators in Chicago

Date Created: 11/26/2024 Date Modified: 12/07/2024
Version of R used: 2024.09.1+394
————————————————————————————————————————————————
Final Project - Extracting and cleaning data 
File: data.R
Required R packages: tidyverse, dplyr, readr, stringr, sf, httr
Project Overview
This project investigates how access to mental health resources and socioeconomic factors influence crime rates in Chicago’s neighborhoods. It involves multiple stages, including downloading raw data, cleaning it, and preparing it for further analysis. The final cleaned data set will be used to perform an Ordinal Least Squares (OLS) regression analysis in the subsequent parts of the project.
Research Question: How do access to mental health resources and socioeconomic factors influence crime rates in Chicago’s neighborhoods?
Data Sources

The datasets needed for the project are the following ones:
- Crime data from 2001 to present (Chicago Data Portal): https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2/about_data. I filtered it before downloading it for years, from 2018 to the present.
Note: I uploaded this data file to Drive since it’s too large for GitHub. You can access it at: https://drive.google.com/drive/folders/1dNOsYoEYDG_DSm9llXdeguCWjRq23-oY?usp=share_link
- CDPH Mental Health Resources (Chicago Data Portal): https://data.cityofchicago.org/Health-Human-Services/CDPH-Mental-Health-Resources/wust-ytyg/about_data
Note: I used the API to retrieve this dataset. On December 3rd, I showed Professor Shi my code. She asked me to make this comment, saying that she authorized my access to the data without an API key.
- Boundaries - Neighborhoods Shapefile (Chicago Data Portal):https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Neighborhoods/bbvz-uum9
- Socioeconomic indicators (Chicago Health Atlas): https://chicagohealthatlas.org
Note: For this dataset, I only selected the following indicators: Perceived neighborhood safety, Perceived neighborhood safety rate, Trust in law enforcement, Trust in law enforcement rate, Trust in local government, Trust in local government rate, Unemployment rate, Median household income, and Poverty rate
- Treatment not Trauma Report (City of Chicago Mental Health System Expansion Website): (https://www.chicago.gov/city/en/sites/treatment-not-trauma/home.html) This pdf was used for web scraping and sentiment analysis.
Summary of Code:
Set Working Directory: The working directory is set to the folder where data files are located. 
Note: Change the working directory as needed
Download and Import Data:
	•	Crime data is loaded from a CSV file.
	•	Health data is fetched from an API endpoint.
	•	Chicago neighborhood boundaries are read from a shapefile.
Data Cleaning:
	•	The crime data is filtered to include only records from 2018 to 2022.
	•	Missing or invalid values are removed.
	•	The Date field is converted to the correct format.
Spatial Data Handling:
	•	Convert crime data to spatial format (sf).
	•	Spatially join the crime data with Chicago's neighborhood boundaries.
	•	Save cleaned spatial data for later analysis and visualization.
Mental Health Data Processing:
	•	Mental health resources are spatially joined with neighborhood boundaries.
	•	The total number of mental health providers and crisis services per neighborhood is summarized.
Socioeconomic Data Processing:
	•	Socioeconomic indicators from the Chicago Health Atlas are cleaned and renamed.
	•	Crime data is merged with socioeconomic indicators based on the neighborhood.
Final Data Merging:
	•	The final dataset is created by merging crime, mental health, and socioeconomic data.
	•	Additional cleaning steps ensure no duplicated columns and proper data types.
Data Export:
	•	Cleaned data is saved as CSV files for later analysis.
	•	Optionally, the user can load archived versions of the dataset.

Key Outputs
	•	Cleaned Crime Data: A CSV file with crime data filtered from 2018 to 2022 and transformed into a spatial format.
	•	Mental Health Data: A CSV file summarizing mental health resources by neighborhood.
	•	Final Merged Data: A cleaned and merged dataset combining crime, mental health, and socioeconomic data, ready for analysis.
	•	RDS Files: Spatial data saved in RDS format for future analysis and visualizations in Shiny apps or other tools.

Files Generated
	1.	narcotics_health_project_data.csv: The final cleaned dataset combines crime, mental health, and socioeconomic data.
	2.	chicago_crime_sf.csv: Since it’s a large file, I also uploaded it to Drive https://drive.google.com/drive/folders/1dNOsYoEYDG_DSm9llXdeguCWjRq23-oY?usp=share_link
	3.	chicago_crime_sf.rds: Spatial data of crime incidents in Chicago neighborhoods.
	4.	mental_health_spatial_data.rds: Spatial data for mental health resources.
	5.	narcotics_spatial_data.rds: Spatial data for narcotics-related crimes.

————————————————————————————————————————————————
Static Plot:  Crime, Narcotics, Mental Health, and Socioeconomic Indicators
File: staticplot.R
Required R packages: tidyverse, dplyr, ggplot2, readr, scales, RColorBrewer, viridis, sf
Overview: This project visualizes various aspects of crime, narcotics-related offenses, mental health resources, and socioeconomic factors in Chicago using static plots. The visualizations provide insight into the distribution of narcotics crimes across neighborhoods, socio-economic conditions, law enforcement trust, unemployment rates, neighborhood safety, and the availability of mental health resources.
File Structure
Input Files:
	•	narcotics_health_project_data.csv - A dataset containing narcotics crime rates, socioeconomic indicators, and mental health resources.
	•	chicago_crime_sf.csv - A Chicago crime record dataset, including spatial coordinates.
	•	narcotics_spatial_data.rds - Spatial data of narcotics-related crimes in Chicago.
	•	mental_health_spatial_data.rds - Spatial data of mental health resources in Chicago.
Output Files:
Static plots saved in the working directory:
	◦	top_ten_crimes_barplot.png
	◦	narcotics_crimes_by_income.png
	◦	narcotics_crimes_by_trust_in_law.png
	◦	narcotics_crimes_by_unemployment.png
	◦	narcotics_crimes_by_safety.png
	◦	narcotics_crimes_heatmap.png
	◦	mental_health_resources_heatmap.png
	◦	crisis_providers_heatmap.png

————————————————————————————————————————————————
Shiny App 1: Crime and Socioeconomic Data Correlation Shiny App
File: shinyapp1.R
Required R packages: shiny, ggplot2, dplyr, sf, dplyr
Overview: This Shiny app is designed to explore the relationship between narcotics-related crimes and mental health resources across different neighborhoods in Chicago. The app visualizes the geographic distribution of narcotics-related arrests and the availability of mental health resources, including crisis services. It allows users to select specific neighborhoods and display options to understand these relationships better.
File Structure
Input Files:

	•	chicago_shape.shp: Chicago neighborhood shapefile.
	•	chicago_narcotics_sf.rds: Spatial data on narcotics-related crimes.
	•	mental_health_resources.rds: Spatial data on mental health resources in Chicago. 
	⁃	Note: Saved in Drive: https://drive.google.com/drive/folders/1dNOsYoEYDG_DSm9llXdeguCWjRq23-oY?usp=sharing

Output Files
	•	Neighborhood Selection: Users can select a specific neighborhood in Chicago or choose to display data for the entire city.
	•	Display Options:
	◦	Narcotics Arrest Heatmap: Visualizes the geographic distribution of narcotics-related arrests across Chicago.
	◦	Heatmap with All Resources: Displays the distribution of all mental health resources available in the city.
	◦	Heatmap with Crisis Services: Shows the locations of crisis mental health services.
	•	Interactive Map: A dynamic map updates based on user input, with data overlays showing narcotics-related arrests and mental health resources.

Summary of Code:
User Interface (UI):
	•	Title panel and Introductory Text: Explain the purpose of the app.
	•	Sidebar Panel:
	◦	A dropdown for selecting a neighborhood or displaying data for all neighborhoods.
	◦	A dropdown for selecting the type of display (heatmap of narcotics arrests, all mental health resources, or crisis services).
	◦	An action button to reset the app to its default state.
	•	The main panel displays the map output based on user input.

Server:
	•	Reactive expressions filter and update data based on user input.
	•	Spatial data is processed to ensure the maps accurately reflect the selected neighborhood and display options.
	•	The app uses ggplot2 to render maps with geom_sf for spatial data visualization.

Map Rendering:
	•	The app generates an interactive map that shows either narcotics-related arrests or mental health resources in the selected area.
	•	Mental health resources, if required, are overlaid on the map, with crisis services shown as blue markers.

————————————————————————————————————————————————
Shiny App 2: Crime and Socioeconomic Data Correlation Shiny App
File: shinyapp2.R
Required R packages: shiny, ggplot2, dplyr, sf
Overview: The Shiny app explores the relationship between crime rates and socioeconomic indicators in Chicago from 2018 to 2022. The app allows users to visualize correlations between reported crime types and relevant socioeconomic factors such as income levels, unemployment rates, and public trust metrics.
File Structure
Input Files:
	•	crime_2018_2022.csv - Crime data reported in Chicago from 2018 to 2022.
	•	narcotics_health_project_data.csv - Socioeconomic indicators by community area.

Output Files:
This Shiny app generates the following outputs dynamically:
	•	Correlation Plot: A scatter plot with a regression line showing the relationship between crimes and selected socioeconomic indicators.
	•	Summary Statistics: Key summary statistics of the merged dataset.

Summary of Code:
User Interface (UI)
Title Panel: Displays the app’s purpose.
Sidebar Panel:
	•	Dropdown Menus: Select crime types and socioeconomic indicators.
	•	Help Text: Guides on how to use the app
Main Panel:
	•	Correlation Plot: A scatter plot showing crime rates vs. socioeconomic factors.
	•	Summary Output: Descriptive statistics for the merged dataset.
Server
Data Loading: Loads and cleans crime and socioeconomic data.
Data Filtering: Filters the dataset by selected crime type.
Data Merging: Joins crime and socioeconomic datasets by Community Area.
Plot Generation:
	•	Generates a scatter plot with a regression line.
	•	Displays selected indicators on axes.
Summary Stats Display: Shows basic statistics of the merged dataset.

Variables
	1.	crime_filtered: Crime dataset filtered by year and type.
	2.	socioeconomic_data: Socioeconomic indicators by community area.
	3.	joined_data(): Merged dataset used for plotting and analysis.

———————————————————————————————————————————————
Text Analysis
File: textprocess.R
Required R packages: rvest, httr, tidyverse, tidytext, textdata, sentimentr, pdftools
Overview: This project focuses on conducting sentiment analysis on the "Treatment Not Trauma" report provided by the City of Chicago. The report is publicly available on the city’s website, and the study involves scraping the report, performing text processing, and generating sentiment visualizations using different sentiment lexicons.
Sentiment analysis leverages various packages for web scraping, text processing, and sentiment evaluation. The results, including sentiment plots, are saved in the current working directory.
Structure of Code:
Web Scraping:
	•	The report is scraped from the City of Chicago website. The PDF link is extracted dynamically.
	•	The PDF is downloaded and stored in the current working directory.

Text Extraction: Text is extracted from the downloaded PDF containing the report's content.
Sentiment Analysis:
	•	The text is tokenized into words and sentences.
	•	The text undergoes pre-processing to remove stopwords.
	•	Sentiment analysis is carried out using three different sentiment lexicons:
	◦	NRC Lexicon: Categorizes words into positive, negative, and emotional categories.
	◦	AFINN Lexicon: Assign a sentiment score between -5 (negative) and +5 (positive) to words.
	◦	Bing Lexicon: Categorizes words as either positive or negative.

Visualization:
	•	Sentiment distributions for each lexicon are visualized using bar plots.
	•	Plots are saved as PNG files in the current working directory.

Sentiment Summary:
	•	The overall sentiment of the report is summarized, including the mean, median, standard deviation, and range (min/max) of sentiment values.

Output
	1	Sentiment Plots:
	◦	Three bar plots are generated and saved as:
	▪	TNT_nrc_plot.png (NRC sentiment distribution).
	▪	TNT_afinn_plot.png (AFINN sentiment score distribution).
	▪	TNT_bing_plot.png (Bing sentiment distribution).
	2	Sentiment Summary:
	◦	A printed summary containing the following statistics:
	▪	Mean sentiment score
	▪	Median sentiment score
	▪	Standard deviation of sentiment scores
	▪	Minimum and maximum sentiment scores

————————————————————————————————————————————————
OLS Model
File: model.R
Required R packages: tidyverse, stargazer, car
Overview: This project performs Ordinary Least Squares (OLS) regression analyses examining the relationship between narcotics crime rates and key mental health and socioeconomic indicators in Chicago. Three OLS models are built incrementally, including additional variables to explore the effects of healthcare resources and socioeconomic conditions on crime rates.
File Structure
Input Files: narcotics_health_project_data.csv
Output Files: Regression Tables
	•	Model 1: Narcotics crime rate vs. total providers.
	•	Model 2: Adds crisis providers and population.
	•	Model 3: Incorporates socioeconomic indicators.

Statistical Checks
I also did a multicollinearity check using the Variance Inflation Factor (VIF) package for Models 2 and 3. 
Note: High VIF (>5) indicates potential multicollinearity issues.

Final Note: For the whole project, I used ChatGPT for debugging and troubleshooting. I had a lot of errors at first, but then I was able to fix them.  After running the codes and saving the files, I had to modify variable names. ChatGPT was very useful in identifying what I needed to change.

