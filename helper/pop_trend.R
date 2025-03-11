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

## Goal: return population estimates for each year using census data each quarter
get_city_trend = function(city) {
  # convert the population into a ts

  city_ts = population_ts |>
    filter(city_st == city)
  
  # years = tibble(year=min(city_ts$year):max(city_ts$year))
  # 
  # years_ts = years |> 
  #   mutate(city_st = "Boston, MA") |>
  #   as_tsibble(key=city_st, index=year)
  # 
  # city_ts_complete = city_ts |>
  #   right_join(years, by=c("year")) |>
  #   arrange(year)
  
  # # get trend
  # pop_model<-city_ts %>% 
  #   model(ETS(pop))
  # 
  # fitted_pop = augment(pop_model, new_data = years_ts) |>
  #   rename(pop_fit = .fitted) # .fitted includes additive error & trend (no seasonality included here)
  
  
  # just smooths for all values, no ETS or time shenanigans
  spline = spline(x=city_ts$year, y=city_ts$pop, xout=min(city_ts$year):max(city_ts$year)) 
  
  fit = data.frame(
    year = spline$x,
    pop = spline$y,
    city_st = city
  )
  
  # check if our fit is any good
  ggplot(aes=aes(x=year,y=pop))+
    geom_line(data=fit,color="blue",aes(x=year,y=pop))+
    geom_line(data=as.data.frame(city_ts),color="red",aes(x=year,y=pop))
  
  return(fit)
}
