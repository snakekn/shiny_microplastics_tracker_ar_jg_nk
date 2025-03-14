# Purpose: run data 

### TO DO TRACKER:
# - filter cities by size
# - filter cities by distance to coast?
# - speed up load?
# - remove all the columns that are created when creating population_coastal (coastal_buffer)
# - get time series finished

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
library(lubridate)
library(tsibble)
# library(plotly)
library(scales)
library(patchwork)
library(feasts)
library(fable)
library(lmtest)
library(car)
library(shinythemes)

## Prepare data 
season_choices = c("Spring", "Summer", "Fall", "Winter") # create static seasonal options

## 1. World Map
world_sf <- ne_countries(scale = "medium", returnclass = "sf")
## 2. Microplastics Data
# source(here::here("helper","microplastic_prep.R")) # builds microplastics.csv
microplastics = read_csv(here::here("data","microplastics.csv"))

## Load constant data types
microplastics$density_class <- factor(microplastics$density_class, 
                                      levels = c("Very Low", "Low", "Medium", "High", "Very High"))

density_palette = c("darkgreen", "lightgreen", "orange", "red", "darkred")
pal_microplastics <- colorFactor(
  palette = density_palette,  # Define colors for each class
  domain = microplastics$density_class  # The categorical variable
)


## 3. City Population data - can do a lot of selecting out here...
# source(here::here("helper","coastal_buffer.R")) # builds population_coastal.csv
population = read.csv(here::here("data","population_coastal.csv")) # Post-buffer population data, 1704 cities!

# fix the data to only show one data point per city
population_unique = population |>
  filter(year==2010)|>
  distinct(city_st, lat, lon, pop) # for making the map counts show up properly
population_unique$pop <- as.numeric(population_unique$pop)

population_unique$pop_rescaled <- (population_unique$pop - min(population_unique$pop)) / 
  (max(population_unique$pop) - min(population_unique$pop)) * 100

## 4. City Population data for our specific 19 cities 
# source(here::here("helper","cities_analysis.R")) # builds population_coastal.csv
source(here::here("helper", "linear_regression.R")) # stores the get_plastic_estimate function
cities_data = read.csv(here::here("data","city_analysis.csv"))
cities_map = cities_data |>
  group_by(city_st) |>
  mutate(pop = max(pop), year=max(year)) |>
  distinct(city_st, lat, lon, marker, pop, year) # for making the map counts show up properly


cities_all_filter = read_csv(here::here("data","cities_all.csv")) |>
  rename(city_st = city)
cities_lr = cities_map |>
  filter(city_st %in% cities_all_filter$city_st) |>
  left_join(cities_all_filter, by="city_st")

pal_city <- colorFactor(
  palette = c("pink","purple"),  # Define colors for each class
  domain = cities_lr$known  # The categorical variable
)

## 5. Microplastics data specifically near our 19 cities
# source(here::here("helper","cities_analysis.R")) # builds population_coastal.csv
city_microplastics = read.csv(here::here("data", "city_microplastic.csv"))

## for building sparkline population trends & getting per-year population estimates
source(here::here("helper","pop_trend.R"))

## for creating time analysis
source(here::here("helper","time_analysis.R"))


######## Workshopping Areas #########

## Alon's Workspace ##


## End Alon's Workspace ##

## Justin's Workspace ##



## End Justin's Workspace ##

## Nadav's Workspace ##


## End Nadav's Workspace ##