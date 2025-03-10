# Goal: Create a little pop vs time for each city to help users understand the local population changes
# Output: Sparkline to insert into population data overlay
create_pop_chart = function(city) {
  data = population |>
    filter(city == !!city) |>
    arrange(year)
  
  pop_data = data |> pull(pop)
  year_data = data |> pull(year)
  
  sparkline_plot <- as.character(
    tags$div(
      tags$script(HTML(sprintf(
        "document.addEventListener('DOMContentLoaded', function() {
                  $('.spark-pop').sparkline([%s], { type: 'line', width: '100px', height: '30px', 
                  lineColor: 'blue', fillColor: 'lightblue', spotColor: 'red', minSpotColor: 'green', maxSpotColor: 'orange' });
                });",
        paste(pop_data, collapse = ",")
      )))
    )
  )
  return(sparkline_plot)
}

# 20 selected cities
cities <- c("Seattle, WA", "Bandon, OR", "San Francisco, CA", "Santa Barbara, CA", 
            "Los Angeles, CA", "San Diego, CA", "Corpus Christi, TX", "Houston, TX", 
            "New Orleans, LA", "Panama City, FL", "Miami, FL", "Jacksonville, FL", 
            "Savannah, GA", "Charleston, SC", "Myrtle Beach, SC", "Virginia Beach, VA", 
            "New York City, NY", "Boston, MA", "Portland, ME")

## get population data without any time gaps
population_no_gaps = population |>
  arrange(year) |>
  distinct(city_st, year, pop) |>
  filter(city_st != "Kailua, HI") |> # has differing population sizes for the same year 
  as_tsibble(key=city_st, index=year)

# get where there are time gaps -- let's skip these areas
gaps = has_gaps(population_no_gaps)

# filter out the gaps
population_ts = population_no_gaps |>
  inner_join(gaps, by="city_st") |>
  filter(.gaps==FALSE,
         city_st %in% cities) |>
  select(-.gaps)

get_city_trend = function(city) {
  # convert the population into a ts
  
  city_ts = population_ts |>
    filter(city_st == city)
  
  # get trend
  pop_model<-city_ts %>% 
    model(ETS(pop~trend(method="A")))
  
  fitted_pop = fitted(pop_model) |>
    rename(pop = .fitted) # .fitted includes additive error & trend (no seasonality included here)
  
  ggplot(aes=aes(x=year,y=pop))+
    geom_line(data=as.data.frame(fitted_pop),color="blue",aes(x=year,y=pop))+
    geom_line(data=as.data.frame(city_ts),color="red",aes(x=year,y=pop))
}
