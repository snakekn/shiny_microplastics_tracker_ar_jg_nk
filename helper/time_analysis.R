# Goal: Conduct time series analysis on microplastics data
# Output: ?

library(lubridate)
library(tsibble)

# pull microplastics data
microplastics = read_csv(here::here("data","microplastics.csv"))

# convert into time data
micro_ts = microplastics |>
  mutate(date=lubridate::ymd(date),lat=round(lat,5),lon=round(lon,5),sample_id = row_number(),
         density_class=as.factor(density_class)) |>
  as_tsibble(key = c(lat,lon,sample_id), index=date,regular=FALSE,.drop=TRUE)

# plot to see how it looks!
ggplot(data = micro_ts, aes(x = date, y = density_class)) +
  geom_() +
  labs(x = "Date",
       y = "Mean daily air temperature (Celsius)\n at Toolik Station")

microplastics_clean <- microplastics |>
  group_by(year, season, density_class, oceans) |>
  summarise(count = n(), .groups = "drop")

# all data
ggplot(microplastics_clean, aes(x = year, y = count, color = density_class)) +
  geom_line(size = 1.2) +
  facet_wrap(~oceans~season) +  # Split by region
  labs(title = "Trends in Microplastic Density Over Time",
       x = "Year",
       y = "Count of Observations",
       color = "Density Class") +
  theme_minimal() +
  theme(legend.position = "bottom")

# create a function that creates a time series analysis plot based on UI selections for viewed map area, season, year, density class
time_series_plot <- function(data, bbox, season, year_range, density_class) {
  data %>%
    filter(lat >= bbox$south & lat <= bbox$north,  
           lon >= bbox$west & lon <= bbox$east,  
           season %in% season,  
           year >= year_range[1] & year <= year_range[2],  
           density_class %in% density_class) %>%
    group_by(date, density_class) %>%  
    summarise(count = n(), .groups = "drop") %>%  # Count occurrences per date/class  
    ggplot(aes(x = date, y = count, color = density_class)) +
    geom_line(size = 1.2) +
    labs(title = "Trends in Microplastic Density Over Time",
         x = "Date",
         y = "Count of Observations",
         color = "Density Class") +
    theme_minimal() +
    theme(legend.position = "bottom")
}

