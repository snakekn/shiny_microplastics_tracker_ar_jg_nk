#### In server.R
# 3. Tourism data - skipping (this data source sucks)
# tourism = read.csv(here::here("data","tourism.csv"), na.string = c("","NA","na")) |> # data needs to be reformatted
#   janitor::clean_names() |>
#   rename(msa = city_msa_visitation,
#          pct_2023 = market,
#          pct_2022 = market_1,
#          visits_2023 = visitation,
#          visits_2022 = visitation_1) |>
#   select(-x,-rank) |>
#   drop_na() |>
#   mutate(pct_2023 = as.numeric(gsub("[%,]","",pct_2023))/100,
#          pct_2022 = as.numeric(gsub("[%,]","",pct_2022))/100,
#          visits_2023 = as.numeric(gsub("[%,]","",visits_2023))*1000,
#          visits_2022 = as.numeric(gsub("[%,]","",visits_2022))*1000)

# need to not have this in our script (it tries geocoding during each open). 
# Do it in another script & save it here
# tourism_geocode = tourism

#### in reactive_data (reactive())

# if (input$show_tourism) {
#   data_list$tourism = tourism
# }
# city_data %>%
#   select(city, lat, lon, variable = all_of(input$map_variable))  # Dynamically select column
#

#### In server() observe()

# # Add Tourism data
# if (input$show_tourism) {
#   leafletProxy("us_map", data = tourism) %>%
#     addCircleMarkers(
#       lng = ~longitude, lat = ~latitude,
#       color = "red", radius = 5,
#       fillOpacity = 0.7,
#       popup = ~paste("Tourism Visits:", visits_2023)  # Modify based on actual column names
#     )
# }