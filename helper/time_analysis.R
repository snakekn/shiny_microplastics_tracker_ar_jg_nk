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






#Justin's Work 

# Drop geometry and convert date column to Date format
plastic_clean_df <- st_drop_geometry(microplastics_clean) %>%
  mutate(date = as.Date(date))

# Aggregate by year and month
plastic_monthly <- plastic_clean_df %>%
  mutate(year = year(date), month = month(date)) %>%
  group_by(year, month) %>%
  summarise(mean_measurement = mean(measurement, na.rm = TRUE), .groups = "drop")

# Apply log1p transformation
plastic_monthly <- plastic_monthly %>%
  mutate(log_mean_measurement = log(mean_measurement+1))

# Create a tsibble
plastic_ts <- plastic_monthly %>%
  mutate(year_month = yearmonth(paste(year, month, sep = "-"))) %>%
  select(year_month, log_mean_measurement) %>%
  as_tsibble(index = year_month)

# Graph
ggplot(data = plastic_ts, aes(x = year_month, y = log_mean_measurement)) +
  geom_line() +
  labs(x = "Date",
       y = "Log(1 + Mean Microplastic Measurement)",
       title = "Monthly Microplastic Levels (Log-Transformed)") +
  theme_minimal()

gg_season(plastic_ts %>% fill_gaps(), y = log_mean_measurement, pal = hcl.colors(n = 9)) +
  theme_minimal() +
  labs(x = "Month",
       y = "Log(1 + Mean Microplastic Measurement)",
       title = "Seasonal Trends in Microplastic Levels")

plastic_ts %>%
  fill_gaps() %>%
  ACF(log_mean_measurement) %>% 
  autoplot()

###########SINCE 2000################

plastic_ts_filtered <- plastic_clean_df %>%
  filter(year >= 2010) %>%
  mutate(date = as.Date(date)) %>%
  mutate(year = year(date), month = month(date)) %>%
  group_by(year, month) %>%
  summarise(mean_measurement = mean(measurement, na.rm = TRUE), .groups = "drop") %>%
  mutate(year_month = yearmonth(paste(year, month, sep = "-"))) %>%
  select(year_month, mean_measurement) %>%
  as_tsibble(index = year_month)

# Apply log transformation
plastic_ts_filtered <- plastic_ts_filtered %>%
  mutate(log_mean_measurement = log(mean_measurement + 1))

# Graph the time series
ggplot(data = plastic_ts_filtered, aes(x = year_month, y = log_mean_measurement)) +
  geom_line() +
  labs(x = "Date", y = "Log of Mean Microplastic Measurement (log-transformed)")

#Seasonal Plot 
gg_season(plastic_ts_filtered %>% fill_gaps(), y = log_mean_measurement, pal = hcl.colors(n = 9)) +
  theme_minimal() +
  labs(x = "Month",
       y = "Log(1 + Mean Microplastic Measurement)",
       title = "Seasonal Trends in Microplastic Levels")


# Check for autocorrelation and plot it
plastic_ts_filtered %>%
  fill_gaps() %>%
  ACF(log_mean_measurement) %>%
  autoplot()

########## ATTEMPTING BY SEASON INSTEAD OF BY MONTH ######################


# Aggregate by year and season using the existing 'year' and 'season' columns
plastic_seasonal <- plastic_clean_df %>%
  group_by(year, season) %>%
  summarise(mean_measurement = mean(measurement, na.rm = TRUE), .groups = "drop")

# Apply log1p transformation
plastic_seasonal <- plastic_seasonal %>%
  mutate(log_mean_measurement = log(mean_measurement + 1))

# Map season to quarters (you can adjust the mapping to suit your data)
season_to_quarter <- c("Winter" = "Q4", "Spring" = "Q1", "Summer" = "Q2", "Fall" = "Q3")

# Create a `year_season` column by mapping season to quarter
plastic_ts_seasonal <- plastic_seasonal %>%
  mutate(
    season_quarter = paste(year, season_to_quarter[season], sep = "-")  # Combine year and quarter
  ) %>%
  # Convert the 'season_quarter' column to 'yearquarter'
  mutate(season_quarter = yearquarter(season_quarter)) %>%
  select(season_quarter, log_mean_measurement) %>%
  as_tsibble(index = season_quarter)

# Plot seasonal trends using ggplot
ggplot(data = plastic_ts_seasonal, aes(x = season_quarter, y = log_mean_measurement)) +
  geom_line() +
  labs(x = "Season",
       y = "Log(1 + Mean Microplastic Measurement)",
       title = "Seasonal Microplastic Levels (Log-Transformed)") +
  theme_minimal()

#Seasonal Decomp Plot 
gg_season(plastic_ts_seasonal %>% fill_gaps(), y = log_mean_measurement, pal = hcl.colors(n = 9)) +
  theme_minimal() +
  labs(x = "Season",
       y = "Log(1 + Mean Microplastic Measurement)",
       title = "Seasonal Trends in Microplastic Levels")




################# SINCE 2000 FOR SEASONS #####################

# Filter the data for years 2000 and onwards
plastic_seasonal <- plastic_clean_df %>%
  filter(year >= 2000) %>%  # Filter by year >= 2000
  group_by(year, season) %>%
  summarise(mean_measurement = mean(measurement, na.rm = TRUE), .groups = "drop")

# Apply log1p transformation
plastic_seasonal <- plastic_seasonal %>%
  mutate(log_mean_measurement = log(mean_measurement + 1))

# Map season to quarters (you can adjust the mapping to suit your data)
season_to_quarter <- c("Winter" = "Q4", "Spring" = "Q1", "Summer" = "Q2", "Fall" = "Q3")

# Create a `year_season` column by mapping season to quarter
plastic_ts_seasonal <- plastic_seasonal %>%
  mutate(
    season_quarter = paste(year, season_to_quarter[season], sep = "-")  # Combine year and quarter
  ) %>%
  # Convert the 'season_quarter' column to 'yearquarter'
  mutate(season_quarter = yearquarter(season_quarter)) %>%
  select(season_quarter, log_mean_measurement) %>%
  as_tsibble(index = season_quarter)

# Plot seasonal trends using ggplot
ggplot(data = plastic_ts_seasonal, aes(x = season_quarter, y = log_mean_measurement)) +
  geom_line() +
  labs(x = "Season",
       y = "Log(1 + Mean Microplastic Measurement)",
       title = "Seasonal Microplastic Levels (Log-Transformed)") +
  theme_minimal()

# Seasonal decomposition plot using gg_season
gg_season(plastic_ts_seasonal %>% fill_gaps(), y = log_mean_measurement, pal = hcl.colors(n = 9)) +
  theme_minimal() +
  labs(x = "Season",
       y = "Log(1 + Mean Microplastic Measurement)",
       title = "Seasonal Trends in Microplastic Levels")

# Autocorrelation plot using ACF
plastic_ts_seasonal %>%
  fill_gaps() %>%
  ACF(log_mean_measurement) %>% 
  autoplot() 








          