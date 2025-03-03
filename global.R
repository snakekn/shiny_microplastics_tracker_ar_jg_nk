# Purpose: run data 

### TO DO TRACKER:
# - filter cities by size
# - filter cities by distance to coast?
# - speed up load?
# - remove all the columns that are created when creating population_coastal (coastal_buffer)
# - get time series finished
# - fix popups & get time series of pop size vs time to show

# loading all libraries centrally for clarity
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
library(markdown)

## Prepare data 

## 1. World Map
world_sf <- ne_countries(scale = "medium", returnclass = "sf")

## 2. Microplastics Data
# source(here::here("helper","microplastic_prep.R")) # builds microplastics.csv
microplastics = read_csv(here::here("data","microplastics.csv"))

## 3. City Population data - can do a lot of selecting out here...
# source(here::here("helper","coastal_buffer.R")) # builds population_coastal.csv
population = read.csv(here::here("data","population_coastal.csv")) # Post-buffer population data, 1704 cities!
population_unique = population |>
  distinct(city_st, lat, lon) # for making the map counts show up properly

## 4. Krig Map
# source(here::here("helper","kriging.R")) # pulls krig info
# krig_raster = ...

## for building sparkline population trends
source(here::here("helper","pop_trend.R"))

## Outdated :)
# source(here::here("helper","tourism.R")) # pulls tourism data

## Load constant data types
pal_microplastics <- colorFactor(
  palette = c("red", "orange", "yellow", "lightgreen", "darkgreen"),  # Define colors for each class
  domain = microplastics$density_class  # The categorical variable
)
season_choices = c("Spring", "Summer", "Fall", "Winter") # create static seasonal options


######## Workshopping Areas #########

## Alon's Workspace ##


## End Alon's Workspace ##

## Justin's Workspace ##



## End Justin's Workspace ##

## Nadav's Workspace ##


## End Nadav's Workspace ##