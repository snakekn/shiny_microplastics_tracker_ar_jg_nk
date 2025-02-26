#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# loading all libraries in the server for clarity
library(shiny)
library(tidyverse)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
# library(readxl)
library(bslib)
# let's try lazy loading if possible, we have a slow start time!
library(magrittr) # data import
library(rvest) # data import
library(leaflet)
library(scales)
library(leaflet.extras)
library(terra)
library(tidyterra)


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
         

# 3. Tourism data - skipping (this data source sucks)
# tourism = read.csv(here::here("data","tourism.csv"), na.string = c("","NA","na")) |> # data needs to be reformatted
#   janitor::clean_names() |>
#   rename(msa = city_msa_visitation,
#          pct_2023 = market,
#          pct_2022 = market_1,
#          visits_2023 = visitation,
#          visits_2022 = visitation_1) |>
#   select(-x,-rank) |>
#   drop_na() |>
#   mutate(pct_2023 = as.numeric(gsub("[%,]","",pct_2023))/100,
#          pct_2022 = as.numeric(gsub("[%,]","",pct_2022))/100,
#          visits_2023 = as.numeric(gsub("[%,]","",visits_2023))*1000,
#          visits_2022 = as.numeric(gsub("[%,]","",visits_2022))*1000)

# need to not have this in our script (it tries geocoding during each open). 
# Do it in another script & save it here
# tourism_geocode = tourism

# 4. City Population data
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
    # if (input$show_tourism) {
    #   data_list$tourism = tourism
    # }
    # city_data %>%
    #   select(city, lat, lon, variable = all_of(input$map_variable))  # Dynamically select column
    # 
    
    
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
      pal_microplastics <- colorFactor(
        palette = c("blue", "green", "yellow", "orange", "red"),  # Define colors for each class
        domain = microplastics$density_class  # The categorical variable
      )

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
    
    # # Add Tourism data
    # if (input$show_tourism) {
    #   leafletProxy("us_map", data = tourism) %>%
    #     addCircleMarkers(
    #       lng = ~longitude, lat = ~latitude,
    #       color = "red", radius = 5,
    #       fillOpacity = 0.7,
    #       popup = ~paste("Tourism Visits:", visits_2023)  # Modify based on actual column names
    #     )
    # }
  }, priority = 1)
}






######## Workshopping Areas #########

## Alon's Workspace ##

# country boundaries
countries <- ne_countries(scale = "medium", returnclass = "sf")
# filter for US 
us_boundaries <- countries |>
  filter(iso_a3 == "USA")
# land boundaries
land <- ne_download(scale = "medium", type = "land", category = "physical", returnclass = "sf")
# filter for US land boundary
us_land <- land[st_intersects(land, us_boundaries, sparse = FALSE), ]
# coastline data
coastline <- ne_download(scale = 10, type = "coastline", category = "physical", returnclass = "sf")
# filter for US coastline
us_coastline <- coastline[st_intersects(coastline, us_boundaries, sparse = FALSE), ]
# 30mi buffer around the coastline
coastline_buffer <- st_buffer(us_coastline, dist = 48280)  # 30 miles in meters
# plot buffer
plot(coastline_buffer, col = "lightblue", border = "blue", lwd = 2)
# Load the population data (cities)
population1 <- read.csv(here::here("data","population.csv")) %>%
  janitor::clean_names() %>%
  pivot_longer(cols = starts_with("x"), names_to = "year", values_to = "pop") %>%
  mutate(year = as.numeric(gsub("^x", "", year))) %>%
  select(-c("id", "stplfips_2010"), -ends_with(c("_bing", "_source"))) %>%
  filter(pop != 0)
# 

## End Alon's Workspace ##

## Justin's Workspace ##


## End Justin's Workspace ##

## Nadav's Workspace ##


## End Nadav's Workspace ##

