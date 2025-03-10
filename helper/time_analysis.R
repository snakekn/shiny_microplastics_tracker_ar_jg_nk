# Goal: Conduct time series analysis on microplastics data
# Output: A time series plot for microplastics data

print("time_analysis.R properly called")

bbox_null = list(
  south = -16.46,
  west = -123,
  north = 56,
  east = -73.7
)

# create a function that creates a time series analysis plot based on UI selections for viewed map area, season, year, density class
build_time_series <- function( bbox=list(
                                south = -16.46,
                                west = -123,
                                north = 56,
                                east = -73.7
                              ), data, seasons, year_range, density_class) {
  # fix in case we're getting reactive data
  if(length(class(bbox)) > 1) { 
    bbox_val = bbox()
  } else {
    bbox_val = bbox
  }
  
  print(bbox_val) # confirm our bbox works
  print(summary(data))
  print(seasons)
  print(year_range)
  print(density_class)
  
  ts_data = data %>%
    filter(lat >= bbox_val$south & lat <= bbox_val$north,  
           lon >= bbox_val$west & lon <= bbox_val$east,  
           season %in% seasons,  
           year >= year_range[1] & year <= year_range[2],  
           density_class %in% density_class)
  
  # check that microplastic data is in the area
  if(nrow(ts_data) == 0) {
    print("No microplastic data in the selected area")
    return(NULL)
  }
  
  ts_whole = ts_data |>
    group_by(date, density_class, season) %>%  
    summarise(count = n(), .groups = "drop") |>  # Count occurrences per date/class  
    ggplot(aes(x = date, y = count, color = density_class)) +
    geom_line(size = 1.2) +
    labs(title = "Trends in Microplastic Density Over Time",
         x = "Date",
         y = "Count of Observations",
         color = "Density Class") +
    theme_bw() +
    scale_color_manual(values=density_palette)+
    theme(legend.position = "bottom")

  ts_facet = ts_data |>
    group_by(date, density_class, season) %>%  
    summarise(count = n(), .groups = "drop") |>  # Count occurrences per date/class  
    ggplot(aes(x = date, y = count, color = density_class)) +
    geom_line(size = 1.2) +
    facet_wrap(~season)+
    labs(title = "Trends in Microplastic Density Over Time",
         x = "Date",
         y = "Count of Observations",
         color = "Density Class") +
    theme_bw() +
    scale_color_manual(values=density_palette)+
    theme(legend.position = "none")

  ts_whole_ly = ggplotly(ts_whole) |> layout(showlegend = FALSE)
  ts_facet_ly = ggplotly(ts_facet)
  ts_complete = subplot(ts_whole_ly,ts_facet_ly,nrows=2,shareX = FALSE, margin=c(0,0,1,1)) |>
    layout(
      showlegend = TRUE,
      margin = list(t=50,b=100)
    )
  print(ts_complete)
  return(ts_complete)
}