# Goal: Conduct time series analysis on microplastics data
# Output: A time series plot for microplastics data

# print("time_analysis.R properly called")

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
  
  # print(bbox_val) # confirm our bbox works
  # print(summary(data))
  # print(seasons)
  # print(year_range)
  # print(density_class)

  ts_data = data %>%
    filter(lat >= bbox_val$south & lat <= bbox_val$north,  
           lon >= bbox_val$west & lon <= bbox_val$east,  
           season %in% seasons,  
           year >= year_range[1] & year <= year_range[2],  
           density_class %in% density_class)

  ts_data = ts_data |>
    filter(unit=="pieces/m3") |>
    mutate(yearmonth = yearmonth(date), year=year(date)) |>
    group_by(density_class, yearmonth, year, season) |>
    summarise(count = n(), avg = mean(measurement), .groups = "drop") 
    # View(ts_data)
  
  # check that microplastic data is in the area
  if(nrow(ts_data) == 0) {
    print("No microplastic data in the selected area")
    return(NULL)
  }
  
  ts_whole = ts_data |>
    ggplot(aes(x = yearmonth, y = avg, color = density_class)) +
    geom_point(size = 1.2) +
    labs(title = "Trends in Microplastic Density Over Time",
         x = "Date",
         y = "Mean Plastics Observation per Day (pieces/m^3)",
         color = "Density Class") +
    theme_bw() +
    scale_color_manual(values=density_palette)+
    theme(legend.position = "bottom")

  ts_facet = ts_data |>
    ggplot(aes(x = yearmonth, y = avg, color = density_class)) +
    geom_point(size = 1.2) +
    facet_wrap(~season, scales = "free")+
    labs(title = "Trends in Microplastic Density Over Time",
         x = "Date",
         y = "Count of Observations",
         color = "Density Class") +
    theme_bw() +
    scale_color_manual(values=density_palette)+
    theme(legend.position = "none")

  ts_complete = ts_whole / ts_facet
  print(ts_complete)
  
  ## now, let's try creating and decomposing the model to check for time series activity
  ts_data_ts = ts_data |>
    as_tsibble(key = c("season", "density_class"), index = yearmonth) |>
    fill_gaps() |>
    tidyr::fill(avg, .direction="down") |>
    mutate(year = yearmonth(yearmonth))
  # View(ts_data_ts)
  
  ts_model = ts_data_ts |>
    model(ARIMA(avg ~ season(method="A")+trend(method="A")))
  ts_predict = broom::augment(ts_model)
  # 
  # components(ts_model) %>%
  #   autoplot() +
  #   theme_minimal()

  return(ts_complete)
}

## for testing!
build_time_series(data=microplastics, seasons=season_choices, year_range=c(1900,2010),density_class=unique(microplastics$density_class))






# Justin's Work 
plastic_clean_df <- st_drop_geometry(microplastics_clean)


# Convert date column to Date format (if it isn't already)
plastic_clean_df <- plastic_clean_df %>%
  mutate(date = as.Date(date))

# Aggregate by year and month
plastic_monthly <- plastic_clean_df %>%
  mutate(year = year(date), month = month(date)) %>%
  group_by(year, month) %>%
  summarise(mean_measurement = mean(measurement, na.rm = TRUE), .groups = "drop")

# Create a tsibble
plastic_ts <- plastic_monthly %>%
  mutate(year_month = yearmonth(paste(year, month, sep = "-"))) %>%
  select(year_month, mean_measurement) %>%
  as_tsibble(index = year_month)

# Graph
ggplot(data = plastic_ts, aes(x = year_month, y = mean_measurement)) +
  geom_line() +
  labs(x = "Date",
       y = "Mean daily air temperature (Celsius)\n at Toolik Station")
