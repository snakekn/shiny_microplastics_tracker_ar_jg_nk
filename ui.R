#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# Goal: Understand how microplastics in our oceans are related to coastal city populations and tourism

# Widget 1: Interactive World map: Users will see a world map with microplastic data for different spots in the oceans near coastal cities. 
## Users will be able to click on those spots and see exact data for how much plastic is in that area. 
## The map will have some filters that include year and season, etc.. 
# ---
### Map: World Map, data points for coastal cities (small dots in blue) & microplastic data (size=microplastic #, opaque, colored red)
### Data Overlay: Click on a city & see the plastic data there (sampling method, density range & class, org, date sampled)
### Filters: Data filters that refresh the page (year, season, type of plastic, anything else we can include from the plastics data)


# Widget 2: Interactive world map: Users will see a world map with tourist and population of coastal cities. (can all be integrated above into one city DB)
## Users will be able to click on those cities to see exact #s for how many tourists visits per year on average, and what is the population of those cities. 
## Map will have some filters like year, season, and switching between tourists info to population info
# ---
### Filter: Hide/show population data & tourism data


# Widget 3: A calculator estimate based on averages from the first two widgets (plastic debris + coastal city population/tourist info) 
## where a user will be able to put in their coastal town/city #s and season/year and get an estimate of how much plastic was present or is present in the surrounding oceans
# ---
### Calculator: User inputs city, year, season
### Calculator can re-create model using data currently shown in the map, and filter out those that aren't being utilized currently
### Calculator spits out LM (LR, RF?) with predictive data on estimate of plastic debris in the ocean  
#### when buffering, turn miles into lat&long and group -> https://gis.stackexchange.com/questions/2951/algorithm-for-offsetting-a-latitude-longitude-by-some-amount-of-meters

# Widget 4: allows you to graphically see trends in pollution over time by using drop downs that let you change the graph by location and time range
## This will be a line graph that shows the amount of plastic in the ocean over time for a specific location
# ---
### User inputs location & time range
### Graph: Line graph, x-axis = time, y-axis = plastic debris

ui = fluidPage(
  
  # Title
  titlePanel("Microplastics & Coastal City Populations"),
  
  # Sidebar with filters
  sidebarLayout(
    sidebarPanel(
      h3("Toggle Data"),
      checkboxInput("show_microplastics","Show Microplastics Data", value=TRUE),
      checkboxInput("show_population","Show Population Data", value=TRUE),

      h3("Filters"),
      
      # Year Slider (1972-2022)
      sliderInput("year_range", "Select Year Range:", 
                  min = min(microplastics$year, na.rm = TRUE),
                  max = max(microplastics$year, na.rm = TRUE),
                  value = c(1972, 2022),  # Default to entire population
                  step = 1, sep = ""),
      
      # Season Checkbox Filter
      checkboxGroupInput("season_filter", "Select Seasons:", 
                         choices = c("Spring", "Summer", "Fall", "Winter"),
                         selected = c("Spring", "Summer", "Fall", "Winter")),  # Default: All selected
        
      
      # Density Class Filter (Dropdown)
      selectInput("density_class_filter", "Density Class:", 
                  choices = unique(microplastics$density_class),
                  selected = unique(microplastics$density_class), 
                  multiple = TRUE), # allows for multiple density types
      
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
        
        # Overview Tab (First) - this explains the point of the app, and how to use it
        tabPanel("Overview", 
                 fluidPage(
                   h2("Overview of the Shiny App"),
                   p("The goal of this project is to understand how plastic pollution in our oceans is related to coastal city populations and tourism. The app provides the following features:"),
                   tags$ul(
                     tags$li("Interactive U.S. map showing plastic data near coastal cities. The map also shows city data (tourism and population)."),
                     tags$li("A plastic debris estimator that calculates plastic debris based on city population and tourist visits."),
                     tags$li("Trend analysis of pollution data over time."),
                   ),
                   h3("How to Use the App"),
                   p("1. Select the year and season to view relevant data."),
                   p("2. Choose the type of plastic you wish to explore (microplastic or macroplastic)."),
                   p("3. View city data (tourism or population) and see its correlation with plastic debris."),
                   p("4. Use the plastic debris estimator to calculate plastic pollution in your city."),
                   p("5. Analyze pollution trends over time to observe changes."),
                   h3("Data Sources"),
                   p("This app uses data from global and local pollution reports, population statistics, and tourism statistics. Data sources are regularly updated to provide the most accurate insights.")
                 )),
        
        # World Map Tab (2nd)
        tabPanel("U.S. Map", leafletOutput("us_map", height = "600px"))
      )
    )
  ),
  theme = bs_theme(
    version = 5,  # Use Bootstrap 5
    bootswatch = "cosmo",  # Try different themes like "darkly", "cosmo", etc.
    primary = "#1E88E5",  # Custom primary color
    secondary = "#D32F2F",  # Secondary color (red)
    success = "#388E3C",  # Success color (green)
    font_scale = 1.1,  # Slightly larger font size
    bg = "#F5F5F5",  # Background color
    fg = "#333333"  # Foreground text color
  ),
)


# 
# # Tab 1: Interactive World Map for Microplastics
# tabPanel("Microplastics Map", 
#          leafletOutput("plastic_map", height = "600px")),
# 
# # Tab 2: Interactive World Map for City Data (Tourism/Population)
# tabPanel("City Data Map", 
#          leafletOutput("city_map", height = "600px")),
# 
# # Tab 3: Plastic Estimator
# tabPanel("Plastic Estimator",
#          verbatimTextOutput("plastic_estimate")),  # Display the model output
# 
# # Tab 4: Pollution Trends Over Time
# tabPanel("Pollution Trends", 
#          plotOutput("trend_graph", height = "500px"))
# ),
# plotOutput("us_map")


######## Workshopping Areas #########

## Alon's Workspace ##


## End Alon's Workspace ##

## Justin's Workspace ##



## End Justin's Workspace ##

## Nadav's Workspace ##


## End Nadav's Workspace ##