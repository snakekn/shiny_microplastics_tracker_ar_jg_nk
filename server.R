#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# loading all libraries in the server for clarity
# let's try lazy loading if possible, we have a slow start time!
library(shiny)
library(tidyverse)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(bslib)
library(magrittr) # data import
library(rvest) # data import
library(leaflet)
library(scales)
library(leaflet.extras)
library(terra)
library(tidyterra)

# source(here::here("helper","krigging.R"))
# source(here::here("helper","coastal_buffer.R"))
# source(here::here("helper","tourism.R"))


# Goal: Understand how microplastics in our oceans are related to coastal city populations and tourism


# Data sources: 
# NCEI Marine Microplastics database provides aggregated microplastic data in marine settings. (noaa_microplastics.csv): https://www.ncei.noaa.gov/products/microplastics
### File Identifier: gov.noaa.ncei:MicroplasticsDatabase (no DOI avaiable)
### Metadata (XML): https://data.noaa.gov/onestop/api/registry/metadata/collection/unknown/b1586022-998a-461e-b969-9d17dde6476c/raw/xml
### Metadata (HTML): https://data.noaa.gov/onestop/api/registry/metadata/collection/unknown/b1586022-998a-461e-b969-9d17dde6476c/raw/html
# UN Population Division Dataset (): https://population.un.org/dataportal/home?df=1214c450-7094-471b-9b36-f0a228414cd5
### - What info do we want to consider? https://population.un.org/wpp/downloads?folder=Standard%20Projections&group=CSV%20format


# - UN Tourism database (unwta_tourism.xlsx): https://www.unwto.org/tourism-statistics/key-tourism-statistics
### Metadata inside the data folder (unwto_tourism_meta.pdf) -- huge pdf so get searching!

# - We may still need to look for more plastic data or if we want to pivot from plastic carbon emission data.

### PREP DATA SOURCES
# 1. World Map
world_sf <- ne_countries(scale = "medium", returnclass = "sf")

# 2. Microplastics Data
microplastics <- read_csv(here::here("data","microplastics.csv")) |> # still needs to have non-USA data removed
  janitor::clean_names() |>
  select(-c("doi","organization","keywords","x","y"),-starts_with("accession"),-ends_with(c("reference", "id"))) |>
  rename(lat=latitude, lon=longitude) |>
  mutate(date = as.Date(date, format = "%m/%d/%Y %I:%M:%S %p"),
         season = case_when(
           month(date) %in% 3:5 ~ "Spring",
           month(date) %in% 6:8 ~ "Summer",
           month(date) %in% 9:11 ~ "Fall",
           TRUE ~ "Winter"
         ),
         year = year(date),
         density_class=factor(density_class,ordered=TRUE,levels=c("Very Low","Low","Medium","High","Very High")),
         density_range=as.factor(density_range),
         unit=as.factor(unit),
         oceans=as.factor(oceans),
         density_marker_size = scales::rescale(as.numeric(density_class), to = c(3, 10))
       )

pal_microplastics <- colorFactor(
  palette = c("blue", "green", "yellow", "orange", "red"),  # Define colors for each class
  domain = microplastics$density_class  # The categorical variable
)

# 3. City Population data
population = read.csv(here::here("data","population.csv"))  |> # do we have the metadata on this?
  janitor::clean_names() |>
  pivot_longer(cols=starts_with("x"),names_to = "year",values_to="pop") |>
  mutate(year = as.numeric(gsub("^x","",year))) |> # remove the x that janitor included for the numeric column names 
  select(-c("id","stplfips_2010"),-ends_with(c("_bing","_source"))) |>
  filter(pop!=0)


# Define server logic required to draw a histogram
server = function(input, output, session) {
  
  filtered_microplastics <- reactive({
    microplastics %>%
      filter(
        season %in% input$season_filter,  # Filter by season
        year >= input$year_range[1] & year <= input$year_range[2],  # Filter by year range
        density_class == input$density_class_filter  # Filter by density class
      )
  })
  
  reactive_data <- reactive({
    
    data_list = list()
    
    if (input$show_microplastics) {
      data_list$microplastics = microplastics
    }
    if (input$show_population) {
      data_list$population = population
    }
    
    return(data_list)
  })

  
  output$us_map <- renderLeaflet({
    # Create the base map
    leaflet() |>
      addTiles() |>  # Default tile layer (OpenStreetMap)
      setView(lng = -98.35, lat = 39.50, zoom = 4)  # Centered on the US
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
  
  observe({
    leafletProxy("us_map") %>%
      clearMarkers() |>
      clearControls()
    
    # Add Microplastics data
    if (input$show_microplastics) {
      leafletProxy("us_map", data = filtered_microplastics()) %>%
        addCircleMarkers(
          lng = ~lon, lat = ~lat,
          radius = ~sqrt(density_marker_size),
          color = ~pal_microplastics(density_class),  # Color by density
          fillOpacity = 0.7,
          popup = ~paste(
            "<strong>Microplastic Count: </strong>", measurement, " (", unit,")<br>",
            "<strong>Density Class: </strong>",density_class, "<br>",
            "<strong>Sampling Method: </strong",sampling_method, "<br>",
            "<strong>Date Collected: </strong>",date)
        ) |>
        addLegend("bottomright", pal = pal_microplastics, values = ~density_class,
                  title = "Microplastic Density", opacity = 1)
    }
    
    # Add Population data
    if (input$show_population) {
      leafletProxy("us_map", data = population) %>%
        addCircleMarkers(
          lng = ~lon, lat = ~lat,
          color = "green", radius = 5,
          fillOpacity = 0.7,
          popup = ~paste("<strong>City:</strong>", city, "<br>",
                         "<strong>Population:</strong>", formatC(pop*1000, format = "d", big.mark = ","))
        )
    }
  })
  
  # 🔄 Update when toggles change
  observeEvent(input$show_microplastics, {
    leafletProxy("us_map") %>%
      clearGroup("microplastics")  # Clears only microplastics markers
    
    if (input$show_microplastics) {
      leafletProxy("us_map", data = filtered_microplastics()) %>%
        addCircleMarkers(
          lng = ~lon, lat = ~lat,
          radius = ~density_marker_size,
          color = ~pal_microplastics(density_class),
          fillOpacity = 0.7,
          popup = ~paste(
            "<strong>Microplastic Count:</strong>", measurement, " (", unit,")<br>",
            "<strong>Density Class:</strong>", density_class, "<br>",
            "<strong>Date Collected:</strong>", date
          ),
          group = "microplastics"
        )
    }
  })
  
  observeEvent(input$show_population, {
    leafletProxy("us_map") %>%
      clearGroup("population")  # Clears only population markers
    
    if (input$show_population) {
      leafletProxy("us_map", data = population) %>%
        addCircleMarkers(
          lng = ~lon, lat = ~lat,
          color = "green", radius = 5,
          fillOpacity = 0.7,
          popup = ~paste(
            "<strong>City:</strong>", city, "<br>",
            "<strong>Population:</strong>", formatC(pop * 1000, format = "d", big.mark = ",")
          ),
          group = "population"
        )
    }
  })
  
  # calculate density based on population
  observeEvent(input$calculate_plastic, {
    
    # Get the center of the current map view
    map_center <- isolate(input$us_map_center)
    
    # If the map center is available, use it; otherwise, set a default location
    lat <- if (!is.null(map_center$lat)) map_center$lat else 39.5
    lon <- if (!is.null(map_center$lng)) map_center$lng else -98.35
    
    # Estimate density_class based on population (simple logic example)
    ## this will require a LM based on a krig!
    estimated_density = "Placeholder Value"
    
    # Add the new marker to the map
    leafletProxy("us_map") %>%
      addCircleMarkers(
        lng = lon, lat = lat,
        color = "purple", fillColor = "purple",
        radius = 8,
        fillOpacity = 0.7,
        popup = paste(
          "<strong>Estimated City:</strong>", input$user_city, "<br>",
          "<strong>Population:</strong>", formatC(input$user_population, format = "d", big.mark = ","), "<br>",
          "<strong>Estimated Density Class:</strong>", estimated_density
        ),
        group = "temporary_marker"
      )
  })
  
  # clear out all the temporary markers we've created
  observeEvent(input$clear_calculations, {
    
    leafletProxy("us_map") %>% clearGroup("temporary_marker")
  })
}






######## Workshopping Areas #########

## Alon's Workspace ##


## End Alon's Workspace ##

## Justin's Workspace ##


## End Justin's Workspace ##

## Nadav's Workspace ##


## End Nadav's Workspace ##

