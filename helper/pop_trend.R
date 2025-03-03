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