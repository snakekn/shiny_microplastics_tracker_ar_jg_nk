ui = fluidPage(
  
  # Title
  titlePanel("Microplastics & Coastal City Populations"),
  
  # Sidebar with filters
  sidebarLayout(
    sidebarPanel(
      accordion(id="select_data",
                open=TRUE,
                accordion_panel("📊 Data Selection",
                                checkboxInput("show_microplastics","Show Microplastics Data", value=FALSE),
                                checkboxInput("show_population","Show Population Data", value=FALSE),
                )),
      accordion(id="filter_data",
                open=FALSE,
                accordion_panel("🔍 Filters",
                                accordion_panel("Plastic Pollution Filters",
                                  # Year Slider (1972-2022)
                                  sliderInput("plastic_year_range", "Year Range:", 
                                              min = min(microplastics$year, na.rm = TRUE),
                                              max = max(microplastics$year, na.rm = TRUE),
                                              value = c(1972, 2022),  # Default to entire population
                                              step = 1, sep = ""),
                                  
                                  # Season Checkbox Filter
                                  selectInput("season_filter", "Collection Season:", 
                                              choices = season_choices,
                                              selected = season_choices,
                                              multiple = TRUE), # allows for multiple density types
                                  
                                  # Density Class Filter
                                  selectInput("density_class_filter", "Density Class:", 
                                              choices = unique(microplastics$density_class),
                                              selected = unique(microplastics$density_class), 
                                              multiple = TRUE), # allows for multiple density types
                                ),
                                accordion_panel("Population Filters",
                                sliderInput("pop_year_range", "Year Range:", 
                                            min = min(microplastics$year, na.rm = TRUE),
                                            max = max(microplastics$year, na.rm = TRUE),
                                            value = c(1972, 2022),  # Default to entire population
                                            step = 1, sep = "")
                                
                                ))),
      accordion(id="calculate_data",
                open=FALSE,
                accordion_panel("🧮 Calculator",
                                
                                ### we don't have this ready :( krig failure
                                # Estimate plastic debris based on local population
                                # h3("Plastic Debris Estimator"),
                                # textInput("user_city", "Enter Coastal City Name:"),
                                # numericInput("user_population", "City Population:", value = 100000),
                                # actionButton("calculate_plastic", "Estimate Plastic Debris"),
                                # br(),
                                # actionButton("clear_calculations","Clear Density Estimates"),
                                # hr(),
                                
                                # Analyze trend in debris based on current 
                                h3("Trend Analysis"),
                                p("Using the current filters above, create a time series plot"),
                                sliderInput("pop_year_range", "Year Range:", 
                                            min = min(microplastics$year, na.rm = TRUE),
                                            max = max(microplastics$year, na.rm = TRUE),
                                            value = c(1972, 2022),  # Default to entire population
                                            step = 1, sep = ""),
                                actionButton("time_series_plot", "Get Time Series Plot")
                ))
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
        tabPanel("U.S. Map", 
                 leafletOutput("us_map", height = "600px"),
                 br(),
                 plotlyOutput("time_series_trend", height="400px")
        )
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
  )
)



######## Workshopping Areas #########

## Alon's Workspace ##


## End Alon's Workspace ##

## Justin's Workspace ##



## End Justin's Workspace ##

## Nadav's Workspace ##


## End Nadav's Workspace ##