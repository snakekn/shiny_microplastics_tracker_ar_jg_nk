ui = fluidPage(
  
  # Title
  titlePanel("Microplastics & Coastal City Populations"),
  
  # Main Panel for displaying maps and plots
  tabsetPanel(id = "tabs",
              
              # Overview Tab (First) - this explains the point of the app, and how to use it
              tabPanel("Overview", value = "overview",
                       column(1),
                       column(10,
                              tags$img(src = "microplastics.jpg", width = "100%", style = "margin-bottom: 20px;"),
                              includeMarkdown("text/about.md")),
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
                                                            )
                                            )
                                  ),
                                  accordion(id="calculate_data",
                                            open=FALSE,
                                            accordion_panel("📆 Get Time Series",
                                                            h3("View Plastics Distribution over Time"),
                                                            p("Using the current filters above, and the current view of the map, create a time series plot of microplastics data."),
                                                            p("(Note: This will send you to the \"Time Series: Microplastics Density by Season\" tab)"),
                                                            actionButton("time_series_plot", "Get Microplastics Time Series Plot")
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
              tabPanel("Time Series: Microplastic Density by Season", value="trend_plastics",
                       plotOutput("time_series_trend",height="400px"),
                       actionButton("return_to_map", "Return to the map"),
                       br(),
                       includeMarkdown("text/plastic_time.md") # what we tried, why it didn't work
              ),
              # LR Map
              tabPanel("Linear Regression: US Map of Analyzed Populations & Microplastics", value="trend_cities",
                       fluidRow( # result currently shows in a modal
                         column(12,
                                wellPanel(
                                  p("The map shows the cities and the localized microplastic data utilized to create a linear model. You can click on city (pink) or plastic sample to learn more about each data point."),
                                  p("Pink dots are cities with fewer than 3 yearly measurements and have an estimated microplastics measurement. Purple dots are cities with 3+ yearly plastic measurements."),
                                  accordion(id="calculate_lr",
                                            open=FALSE,
                                            accordion_panel("🧮 Calculate Expected Microplastics for a City Population",
                                                            p("Input a population size, and we'll attempt to find an expected microplastics measurement."),
                                                            p("NOTE: The linear model is a poor indicator of total variance in the microplastics data. Due to how poorly population predicts microplastic density, the model always outputs a medium density of microplastics. The team needs to collect more data to improve this model. Please read the disclosure below the map to learn more."),
                                                            numericInput("est_pop", "City Population:", value = 1e6, min = 0),
                                                            actionButton("est_plastic", "Estimate Plastic Measurement Averages Near the City")
                                            )
                                  )
                                )
                         )
                       ),
                       fluidRow(
                         column(12,
                                accordion(id="linear_disclosure", open=FALSE,
                                          accordion_panel("Disclosure on the Linear Regression Process",
                                                          includeMarkdown("text/linear_regression_p1.md"), # what we tried, why it didn't work
                                                          tags$img(src="linear_manipulation.jpg", width="60%"), # show the plot image
                                                          includeMarkdown("text/linear_regression_p2.md"), # what we tried, why it didn't work
                                                          tags$img(src="lin_reg.jpg",width="60%") # show the linear regression and how poor it is
                                          )
                                ),
                                br(),
                                leafletOutput("trend_map",height="600px"),
                         )
                       )
                       
              ), tabPanel("Kriging Analysis & Challenges", value = "kriging_analysis",
                          fluidRow(
                            column(12,
                                   wellPanel(
                                     includeMarkdown("text/krig.md"),
                                     tags$img(src="Atlantic.png", width="100%"),
                                     tags$img(src="PugetSound.png", width="100%"),
                                     tags$img(src="Miami.png", width="100%"),
                                     tags$img(src="NE.png", width="100%"),
                                     tags$img(src="BayArea.png", width="100%"),
                                     tags$img(src="Tampa.png", width="100%")
                                   )
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