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
