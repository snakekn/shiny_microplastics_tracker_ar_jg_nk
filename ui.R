# Goal: Understand how microplastics in our oceans are related to coastal city populations

# Widget 1: Interactive World map: Users will see a world map with microplastic data for different spots in the oceans near coastal cities. 
## Users will be able to click on those spots and see exact data for how much plastic is in that area. 
## The map will have some filters that include year and season, etc.. 
# ---
### Map: World Map, data points for coastal cities (small dots in blue) & microplastic data (size=microplastic #, opaque, colored red)
### Data Overlay: Click on a city & see the plastic data there (sampling method, density range & class, org, date sampled)
### Filters: Data filters that refresh the page (year, season, type of plastic, anything else we can include from the plastics data)


# Widget 2: Interactive world map: Users will see a world map with  population of coastal cities. (can all be integrated above into one city DB)
## Users will be able to click on those cities to see exact #s for the population of those cities. 
## Map will have some filters like year, season, and density, etc
# ---
### Filter: Hide/show population data


# Widget 3: A calculator estimate based on averages from the first two widgets (plastic debris + coastal city population info) 
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
                         choices = season_choices,
                         selected = season_choices),  # Default: All selected
        
      
      # Density Class Filter (Dropdown)
      selectInput("density_class_filter", "Density Class:", 
                  choices = unique(microplastics$density_class),
                  selected = unique(microplastics$density_class), 
                  multiple = TRUE), # allows for multiple density types
      
      hr(),
      
      # Estimate plastic debris based on local population
      h3("Plastic Debris Estimator"),
      textInput("user_city", "Enter Coastal City Name:"),
      numericInput("user_population", "City Population:", value = 100000),
      actionButton("calculate_plastic", "Estimate Plastic Debris"),
      br(),
      actionButton("clear_calculations","Clear Density Estimates"),
      hr(),
      
      # Analyze trend in debris based on year
      h3("Trend Analysis"),
      selectInput("trend_location", "Select Location:", choices = NULL),  # To be updated dynamically
      sliderInput("time_range", "Select Time Range:", min = 2000, max = 2025, value = c(2010, 2025)),
      actionButton("update_trend", "Update Graph")
    ),
    
    # Main Panel for displaying maps and plots
    mainPanel(
      tabsetPanel(id = "tabs",
        
        # Overview Tab (First) - this explains the point of the app, and how to use it
        tabPanel("Overview", 
                 column(1),
                 column(10,includeMarkdown("text/about.md")),
                 column(1)
                 ), # end the overview page
        
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



######## Workshopping Areas #########

## Alon's Workspace ##


## End Alon's Workspace ##

## Justin's Workspace ##



## End Justin's Workspace ##

## Nadav's Workspace ##


## End Nadav's Workspace ##