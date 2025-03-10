# Define server logic required to draw a histogram
server = function(input, output, session) {
  
  # Reactive value to store map bounds
  map_bounds <- reactiveVal(NULL)
  print(map_bounds)
  
  # Update map bounds when it changes
  observe({
    if (is.null(input$us_map_bounds)) {
      print("No bounds detected yet, setting default.")
      
      # Default bounding box (approximate US bounds)
      leafletProxy("us_map") %>%
        fitBounds(-125, 24, -66, 49)
      map_bounds(input$us_map_bounds)
      print(map_bounds)
    }
  })
  
  observeEvent(input$us_map_bounds, {
    print("Updated map bounds detected:")
    print(input$us_map_bounds)
    map_bounds(input$us_map_bounds)  # Store bounds safely
  })
  
  # Ensure the map triggers bounds updates
  observeEvent(input$us_map_zoom, { 
    print("Zoom event detected")
  })
  observeEvent(input$us_map_center, { 
    print("Center event detected")
  })
  
  
  filtered_microplastics <- reactive({
    microplastics %>%
      filter(
        season %in% input$season_filter,  # Filter by season
        year >= input$plastic_year_range[1] & year <= input$plastic_year_range[2],  # Filter by year range
        density_class %in% input$density_class_filter  # Filter by density class
      )
  })
  
  output$us_map <- renderLeaflet({ # create the initial map
    # Create the base map
    leaflet() |>
      addTiles() |>  # Default tile layer (OpenStreetMap)
      setView(lng = -98.35, lat = 39.50, zoom = 4)  # Centered on the US
  })
  
  # map for city analysis
  output$trend_map <- renderLeaflet({ # create the initial map
    # Create the base map
    leaflet() |>
      addTiles() |>  # Default tile layer (OpenStreetMap)
      setView(lng = -98.35, lat = 39.50, zoom = 4) |> # Centered on the US
      addCircleMarkers( # show cities
        data = cities_map,
        lng = ~lon, lat = ~lat,
        radius = ~marker,
        color = "black",      # Outline color
        fillColor = "hotpink", 
        fillOpacity = 0.7,
        options = markerOptions(count = 1),
        layerId = ~city_st,
        group = "cities",
        popup = ~paste0(
          "<strong>City Name: </strong>", city_st, "<br>",
          "<strong>Population: </strong>", format(pop,big.mark = ','), " (",as.character(year),")<br>"
        )
      )
  #     addCircleMarkers( # show plastics
  #       data = city_19_unique,
  #       lng = ~lon, lat = ~lat,
  #       radius = marker_radius,
  #       color = "black",      # Outline color
  #       fillColor = "hotpink", 
  #       fillOpacity = 0.7,
  #       options = markerOptions(count = 1),
  #       layerId = ~city_st,
  #       group = "plastics"
  #     )
   })
  
  # Create a reactive expression for the calculator
  output$calculator <- renderUI({
    # Create a form for the user to input data
    tagList(
      textInput("city", "City"),
      numericInput("year", "Year", value = 2021),
      selectInput("season", "Season", choices = season_choices),
      actionButton("calculate", "Calculate")
    )
  })
  
  observe({ # on an edit, re-print data
    # Add microplastics data
    if (input$show_microplastics) {
      leafletProxy("us_map", data = filtered_microplastics()) %>%
        clearGroup("microplastics") |>
        addCircleMarkers(
          lng = ~lon, lat = ~lat,
          # was hoping to cluster & show via a cool icon with density info within, but needed to reprioritize my time :(
          radius = ~sqrt(density_marker_size),
          color = ~pal_microplastics(density_class),  # Color by density
          fillOpacity = 0.7,
          popup = ~paste(
            "<strong>Microplastic Count: </strong>", measurement, " (", unit,")<br>",
            "<strong>Density Class: </strong>",density_class, "<br>",
            "<strong>Sampling Method: </strong",sampling_method, "<br>",
            "<strong>Date Collected: </strong>",date,
            "<strong>Ocean: </strong>", oceans
          ),
          group="microplastics"
        ) |>
        addLegend("bottomright", pal = pal_microplastics, values = ~density_class,
                  title = "Microplastic Density", opacity = 1, layerId = "microplastic_legend")
    } else {
      leafletProxy("us_map") %>%
        clearGroup("microplastics") |>
        removeControl("microplastic_legend")
    }
    
    # Function for Marker Size 
 
    # Add Population data
    if (input$show_population) {
      leafletProxy("us_map", data = population_unique) |>
        clearGroup("population") |>
        addCircleMarkers(
          lng = ~lon, lat = ~lat,
          clusterOptions = markerClusterOptions(
            spiderfyOnMaxZoom = FALSE, removeOutsideVisibleBounds = FALSE, disableClusteringAtZoom = 10,
            showCoverageOnHover = TRUE,   zoomToBoundsOnClick = TRUE
          ),
          radius = ~pop_rescaled,
          color = "black",      # Outline color
          fillColor = "hotpink", 
          fillOpacity = 0.7,
          options = markerOptions(count = 1),
          layerId = ~city_st,
          group="population"
        )
    } else {
      leafletProxy("us_map") %>%
        clearGroup("population")
    }
  })
  
  observeEvent(input$us_map_marker_click, { # generic name format for marker clicks: "MAPID_marker_click"

    click = input$us_map_marker_click # for ease
    print(click)
    if (is.null(click$id)) return()
    
    clicked_city = click$id
    if (clicked_city %in% population_unique$city_st) {
    
      # Get clicked city
      clicked_city <- input$us_map_marker_click
      print(clicked_city)
      
      # Ensure a valid city is clicked
      if (is.null(clicked_city)) return()
      
      # Extract city name
      city_name <- clicked_city$id  # Ensure your markers have IDs matching city names
      
      # Subset the population data for the clicked city
      city_data <- population %>% filter(city_st == city_name) |>
        select(year,pop)
      print(city_data)
      print(min(city_data$year))
      print(max(city_data$year))
  
      # get datapoints to discuss 
      total = count(city_data)
      range = max(city_data$year) - min(city_data$year) + 1
      
      # Generate sparkline dynamically
      output$sparkline <- {
        if (total == 1) {
          plotly::renderPlotly({
            plotly::ggplotly(
              ggplot(city_data, aes(y = pop)) +
                geom_bar(color = "blue") +
                theme_bw() +
                scale_fill_viridis_d()+
                labs(title = paste("Population Size in", city_data$year), y = "Population")
            )}
          )
        } else {
          plotly::renderPlotly({
          plotly::ggplotly(
            ggplot(city_data, aes(x = year, y = pop)) +
            geom_line(color = "blue") +
            theme_bw() +
            scale_fill_viridis_d()+
            labs(title = paste("Population Trend for", city_name), x = "Year", y = "Population")
            )}
          )
        }
      }
      
      showModal(modalDialog(
        title=paste("City: ",city_name),
        paste0("Showing population data across ", range, " year(s) [", total, " data point(s)]\n"),
        plotly::plotlyOutput("sparkline"),
        easyClose=TRUE
      ))
    }
  })
  
  ## removed as we recently got rid of this functionality 
  # calculate density based on population
  # observeEvent(input$calculate_plastic, {
  #   
  #   # Get the center of the current map view
  #   map_center <- isolate(input$us_map_center)
  #   
  #   # If the map center is available, use it; otherwise, set a default location
  #   lat <- if (!is.null(map_center$lat)) map_center$lat else 39.5
  #   lon <- if (!is.null(map_center$lng)) map_center$lng else -98.35
  #   
  #   # Estimate density_class based on population (simple logic example)
  #   ## this will require a LM based on a krig!
  #   estimated_density = "Placeholder Value"
  #   
  #   # Add the new marker to the map
  #   leafletProxy("us_map") %>%
  #     addCircleMarkers(
  #       lng = lon, lat = lat,
  #       color = "purple", fillColor = "purple",
  #       radius = 8,
  #       fillOpacity = 0.7,
  #       popup = paste(
  #         "<strong>Estimated City:</strong>", input$user_city, "<br>",
  #         "<strong>Population:</strong>", formatC(input$user_population, format = "d", big.mark = ","), "<br>",
  #         "<strong>Estimated Density Class:</strong>", estimated_density
  #       ),
  #       group = "temporary_marker"
  #     )
  # })
  
  # clear out all the temporary markers we've created
  # observeEvent(input$clear_calculations, {
  #   
  #   leafletProxy("us_map") %>% clearGroup("temporary_marker")
  # })
  
  ts_plot_data <- reactive({
    req(map_bounds, input$season_filter, input$plastic_year_range, input$density_class_filter)
    
    build_time_series(
      data = microplastics,
      bbox = map_bounds,
      season = input$season_filter,
      year_range = input$plastic_year_range,
      density_class = input$density_class_filter
    )
  })
  
  # create time series plot
  observeEvent(input$time_series_plot, {
    print(map_bounds)
    print(input$season_filter)
    print(input$plastic_year_range)
    print(input$density_class_filter)
    
    req(ts_plot_data)
    
    print("after req")
    
    output$time_series_trend <- renderPlotly({
      print("inside plot function")
      print(ts_plot_data())
      ggplotly(ts_plot_data()) |> 
        layout(title="Microplastic Density Trends", hovermode = "x")
    })
  })
  
  
}






######## Workshopping Areas #########

## Alon's Workspace ##

## End Alon's Workspace ##

## Justin's Workspace ##


## End Justin's Workspace ##

## Nadav's Workspace ##


## End Nadav's Workspace ##

