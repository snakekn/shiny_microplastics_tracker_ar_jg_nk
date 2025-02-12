#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(tidyverse)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(readxl)
library(bslib)
# Goal: Understand how microplastics in our oceans are related to coastal city populations and tourism


# Data sources: 
# NCEI Marine Microplastics database provides aggregated microplastic data in marine settings. (noaa_microplastics.csv): https://www.ncei.noaa.gov/products/microplastics
### File Identifier: gov.noaa.ncei:MicroplasticsDatabase (no DOI avaiable)
### Metadata (XML): https://data.noaa.gov/onestop/api/registry/metadata/collection/unknown/b1586022-998a-461e-b969-9d17dde6476c/raw/xml

# UN Population Division Dataset (): https://population.un.org/dataportal/home?df=1214c450-7094-471b-9b36-f0a228414cd5
### - What info do we want to consider? https://population.un.org/wpp/downloads?folder=Standard%20Projections&group=CSV%20format


# - UN Tourism database (unwta_tourism.xlsx): https://www.unwto.org/tourism-statistics/key-tourism-statistics
### Metadata inside the data folder (unwto_tourism_meta.pdf) -- huge pdf so get searching!

# - We may still need to look for more plastic data or if we want to pivot from plastic carbon emission data.

### PREP DATA SOURCES

# Load the data
microplastics <- read_csv(here::here("data","noaa_microplastics.csv")) |>
  janitor::clean_names()
# lubridate the year, 

# convert in format 5/21/2001 12:00:00 AM to date
microplastics$date <- as.Date(microplastics$date, format = "%m/%d/%Y %I:%M:%S %p")

# Doesn't exist yet - population <- read_csv(here::here("data","un_population.csv"))
tourism <- readxl::read_xlsx(here::here("data","unwto_tourism.xlsx")) # data needs to be reformatted

# bring in world map
world_sf <- ne_countries(scale = "medium", returnclass = "sf")

# Merge the population data with the world map - doesn't work yet
# world_population <- left_join(world, population, by = c("name" = "city"))

# Merge the tourism data with the world map - doesn't work yet
# world_tourism <- left_join(world, tourism, by = c("name" = "city"))


# Define server logic required to draw a histogram
server = function(input, output, session) {
  
  reactive_data <- reactive({
    city_data %>%
      select(city, lat, lon, variable = all_of(input$map_variable))  # Dynamically select column
  })
  
  # Render Leaflet Map
  output$map <- renderLeaflet({
    leaflet(city_data) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = ~lon, lat = ~lat,
        label = ~paste(city, "<br>", input$map_variable, ":", variable),
        color = "blue",
        radius = ~variable * 2,  # Scale marker size
        fillOpacity = 0.7
      )
  })
  
  # Create a reactive expression for the population map
  output$population_map <- renderLeaflet({
    leaflet(world_population) %>%
      addTiles() %>%
      addCircleMarkers(
        radius = ~population,
        color = "blue",
        fillOpacity = 0.8
      )
  })
  
  # Create a reactive expression for the tourism map
  output$tourism_map <- renderLeaflet({
    leaflet(world_tourism) %>%
      addTiles() %>%
      addCircleMarkers(
        radius = ~tourism,
        color = "green",
        fillOpacity = 0.8
      )
  })
  
  # Create a reactive expression for the calculator
  output$calculator <- renderUI({
    # Create a form for the user to input data
    tagList(
      textInput("city", "City"),
      numericInput("year", "Year", value = 2021),
      selectInput("season", "Season", choices = c("Spring", "Summer", "Fall", "Winter")),
      actionButton("calculate", "Calculate")
    )
  })
 
  
  # Update the map on a new event
  observeEvent(input$refresh, {
    leafletProxy("map", data = reactive_data()) %>%
      clearMarkers() %>%
      addCircleMarkers(
        lng = ~lon, lat = ~lat,
        label = ~paste(city, "<br>", input$map_variable, ":", variable),
        color = "blue",
        radius = ~variable * 2,
        fillOpacity = 0.7
      )
  })
}
