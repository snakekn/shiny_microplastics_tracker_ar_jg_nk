ui = fluidPage(
  
  # Title
  titlePanel("Microplastics & Coastal City Populations"),
  
  # Main Panel for displaying maps and plots
  tabsetPanel(id = "tabs",
              
              # Overview Tab (First) - this explains the point of the app, and how to use it
              tabPanel("Overview", value = "overview",
                       column(1),
                       column(10,includeMarkdown("text/about.md")),
                       column(1)
              ), # end the overview page
              
              # World Map Tab (2nd)
              tabPanel("US Map of all Populations & Microplastics", value = "all_data",
                       fluidRow(
                         column(12,
                                wellPanel(
                                  accordion(id="select_data",
                                            open=TRUE,
                                            accordion_panel("📊 Data Selection",
                                                            checkboxInput("show_microplastics","Show Microplastics Data", value=TRUE),
                                                            checkboxInput("show_population","Show Population Data", value=TRUE)
                                            )
                                  ),
                                  accordion(id="filter_data",
                                            open=FALSE,
                                            accordion_panel("🔍 Filters",
                                                            accordion_panel("Plastic Pollution Filters",
                                                                            sliderInput("plastic_year_range", "Year Range:", 
                                                                                        min = min(microplastics$year, na.rm = TRUE),
                                                                                        max = max(microplastics$year, na.rm = TRUE),
                                                                                        value = c(1972, 2022), step = 1, sep = ""),
                                                                            selectInput("season_filter", "Collection Season:", 
                                                                                        choices = season_choices,
                                                                                        selected = season_choices,
                                                                                        multiple = TRUE),
                                                                            selectInput("density_class_filter", "Density Class:", 
                                                                                        choices = unique(microplastics$density_class),
                                                                                        selected = unique(microplastics$density_class), 
                                                                                        multiple = TRUE)
                                                            ),
                                                            accordion_panel("Population Filters",
                                                                            sliderInput("pop_year_range", "Year Range:", 
                                                                                        min = min(microplastics$year, na.rm = TRUE),
                                                                                        max = max(microplastics$year, na.rm = TRUE),
                                                                                        value = c(1972, 2022), step = 1, sep = "")
                                                            )
                                            )
                                  ),
                                  accordion(id="calculate_data",
                                            open=FALSE,
                                            accordion_panel("🧮 Calculator",
                                                            h3("Trend Analysis"),
                                                            p("Using the current filters above, create a time series plot. <br> (Note: This will send you to the \"Calculated Microplastics Density Trends\" tab)"),
                                                            actionButton("time_series_plot", "Get Time Series Plot")
                                            )
                                  )
                                )
                         )
                       ),
                       fluidRow(
                         column(12,
                                leafletOutput("us_map", height = "600px")
                         )
                       )
                       
              ),
              #microplastic density trends
              tabPanel("Calculated Microplastic Density Trends", value="trend_plastics",
                       plotOutput("time_series_trend",height="400px"),
                       actionButton("return_to_map", "Return to the map")
                       
              ),
              # LR Map
              tabPanel("US Map of Analyzed Populations & Microplastics", value="trend_cities",
                       leafletOutput("trend_map",height="600px")
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