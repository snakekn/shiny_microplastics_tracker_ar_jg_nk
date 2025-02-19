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
# 1. World Map
world_sf <- ne_countries(scale = "medium", returnclass = "sf")

# 2. Microplastics Data
microplastics_raw = read_csv(here::here("data","microplastics.csv"))

microplastics <- read_csv(here::here("data","microplastics.csv")) |> # still needs to have non-USA data removed
  janitor::clean_names() |>
  select(-c("doi","organization","keywords","x","y"),-starts_with("accession"),-ends_with(c("reference", "id"))) |>
  rename(lat=latitude, lon=longitude) |>
  mutate(date = as.Date(microplastics$date, format = "%m/%d/%Y %I:%M:%S %p"),
         season = case_when(
           month(date) %in% 3:5 ~ "Spring",
           month(date) %in% 6:8 ~ "Summer",
           month(date) %in% 9:11 ~ "Fall",
           TRUE ~ "Winter"
         ))

# 3. Tourism data
tourism = read.csv(here::here("data","tourism.csv"), na.string = c("","NA","na")) |> # data needs to be reformatted
  janitor::clean_names() |>
  rename(msa = city_msa_visitation,
         pct_2023 = market,
         pct_2022 = market_1,
         visits_2023 = visitation,
         visits_2022 = visitation_1) |>
  select(-x,-rank) |>
  drop_na() |>
  mutate(pct_2023 = as.numeric(gsub("[%,]","",pct_2023))/100,
         pct_2022 = as.numeric(gsub("[%,]","",pct_2022))/100,
         visits_2023 = as.numeric(gsub("[%,]","",visits_2023))*1000,
         visits_2022 = as.numeric(gsub("[%,]","",visits_2022))*1000)

tourism_geocode = tourism |>
  tidygeocoder::geocode(city = msa, method = "osm", lat = latitude, long = longitude) # doesn't work on msa data :(

# 4. City Population data
population = read.csv(here::here("data","population.csv"))  |> # do we have the metadata on this?
  janitor::clean_names() |>
  pivot_longer(cols=starts_with("x"),names_to = "year",values_to="pop") |>
  mutate(year = as.numeric(gsub("^x","",year))) |> # remove the x that janitor included for the numeric column names 
  select(-c("id","stplfips_2010"),-ends_with(c("_bing","_source"))) |>
  filter(pop!=0)


# Define server logic required to draw a histogram
server = function(input, output, session) {
  
  reactive_data <- reactive({
    city_data %>%
      select(city, lat, lon, variable = all_of(input$map_variable))  # Dynamically select column
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






######## Workshopping Areas #########

## Alon's Workspace ##


## End Alon's Workspace ##

## Justin's Workspace ##



## End Justin's Workspace ##

## Nadav's Workspace ##


## End Nadav's Workspace ##

