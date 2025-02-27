# Purpose: run data 

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
library(markdown)

## Prepare data 

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

# 3. City Population data
population = read.csv(here::here("data","population.csv"))  |> # do we have the metadata on this?
  janitor::clean_names() |>
  pivot_longer(cols=starts_with("x"),names_to = "year",values_to="pop") |>
  mutate(year = as.numeric(gsub("^x","",year))) |> # remove the x that janitor included for the numeric column names 
  select(-c("id","stplfips_2010"),-ends_with(c("_bing","_source"))) |>
  filter(pop!=0)

## Advanced data methods
# source(here::here("helper","krigging.R")) # pulls krig info
# source(here::here("helper","coastal_buffer.R")) # pulls coastal limits

## Outdated :)
# source(here::here("helper","tourism.R")) # pulls tourism data

## Load constant data types
pal_microplastics <- colorFactor(
  palette = c("blue", "green", "yellow", "orange", "red"),  # Define colors for each class
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