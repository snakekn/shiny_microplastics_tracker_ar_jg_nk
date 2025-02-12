#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(magrittr) # data import
library(rvest) # data import
library(leaflet)

# Goal: Understand how microplastics in our oceans are related to coastal city populations and tourism

# Widget 1: Interactive World map: Users will see a world map with microplastic data for different spots in the oceans near coastal cities. 
## Users will be able to click on those spots and see exact data for how much plastic is in that area. 
## The map will have some filters that include year and season, etc.. 
# ---
### Map: World Map, data points for coastal cities (small dots in blue) & microplastic data (size=microplastic #, opaque, colored red)
### Data Overlay: Click on a city & see the plastic density (?) there
### Filters: Data filters that refresh the page (year, season, type of plastic, anything else we can include from the plastics data)


# Widget 2: Interactive world map: Users will see a world map with tourist and population of coastal cities. (can all be integrated above into one city DB)
## Users will be able to click on those cities to see exact #s for how many tourists visits per year on average, and what is the population of those cities. 
## Map will have some filters like year, season, and switching between tourists info to population info
# ---

# Widget 3: A calculator estimate based on averages from the first two widgets (plastic debris + coastal city population/tourist info) 
## where a user will be able to put in their coastal town/city #s and season/year and get an estimate of how much plastic was present or is present in the surrounding oceans
# ---
### Calculator: User inputs city, year, season
### Calculator can re-create model using data currently shown in the map, and filter out those that aren't being utilized currently
### Calculator spits out LM (LR, RF?) with predictive data on estimate of plastic debris in the ocean  

# Widget 4: allows you to graphically see trends in pollution over time by using drop downs that let you change the graph by location and time range
## This will be a line graph that shows the amount of plastic in the ocean over time for a specific location
# ---
### User inputs location & time range
### Graph: Line graph, x-axis = time, y-axis = plastic debris


library(shiny)
library(leaflet)

ui = fluidPage(
  
  # Title
  titlePanel("Microplastics & Coastal City Populations"),
  
  # Sidebar with filters
  sidebarLayout(
    sidebarPanel(
      h3("Filters"),
      selectInput("year", "Select Year:", choices = 2000:2025, selected = 2023),
      selectInput("season", "Select Season:", choices = c("Spring", "Summer", "Fall", "Winter")),
      selectInput("plastic_type", "Type of Plastic:", choices = c("All", "Microplastic", "Macroplastic")),
      selectInput("city_data", "City Data Display:", choices = c("Tourism", "Population")),
      actionButton("update_map", "Update Map"),
      hr(),
      h3("Plastic Debris Estimator"),
      textInput("user_city", "Enter Coastal City Name:"),
      numericInput("user_population", "City Population:", value = 100000),
      numericInput("user_tourists", "Tourist Visits Per Year:", value = 500000),
      actionButton("calculate_plastic", "Estimate Plastic Debris"),
      hr(),
      h3("Trend Analysis"),
      selectInput("trend_location", "Select Location:", choices = NULL),  # To be updated dynamically
      sliderInput("time_range", "Select Time Range:", min = 2000, max = 2025, value = c(2010, 2025)),
      actionButton("update_trend", "Update Graph")
    ),
    
    # Main Panel for displaying maps and plots
    mainPanel(
      tabsetPanel(
        
        # Tab 1: Interactive World Map for Microplastics
        tabPanel("Microplastics Map", 
                 leafletOutput("plastic_map", height = "600px")),
        
        # Tab 2: Interactive World Map for City Data (Tourism/Population)
        tabPanel("City Data Map", 
                 leafletOutput("city_map", height = "600px")),
        
        # Tab 3: Plastic Estimator
        tabPanel("Plastic Estimator",
                 verbatimTextOutput("plastic_estimate")),  # Display the model output
        
        # Tab 4: Pollution Trends Over Time
        tabPanel("Pollution Trends", 
                 plotOutput("trend_graph", height = "500px"))
      )
    )
  )
)