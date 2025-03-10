# Purpose: Get coastal boundaries to reduce city loads
# Output: Cities (1704) within 30mi of US coastal boundaries

# get US country boundary
us_boundary <- ne_countries(scale = "medium", returnclass = "sf") |>
  filter(iso_a3 == "USA")

# get crs to confirm we're matching up across all datasets
country_crs = st_crs(us_boundary)
country_crs # 4326

# coastline data
coastline <- ne_coastline(scale="medium",returnclass="sf")

# filter for US coastline
us_coastline = st_intersection(coastline, us_boundary)

# check our progress!
#plot(st_geometry(us_coastline),col="darkblue",lwd=2)
#plot(st_geometry(us_boundaries), add = TRUE, border = "red")

# project before buffering
us_coast_proj = st_transform(us_coastline,crs=5070)

# get 30mi buffer
coastline_buffer <- st_buffer(us_coast_proj, dist = 48280)  # 30 miles in meters

# back to 4326
coastline_buffer_wgs = st_transform(coastline_buffer,crs=4326)

# check buffer results!
#plot(st_geometry(coastline_buffer_wgs), col = "lightblue", border = "blue", lwd = 2)
#plot(st_geometry(us_coastline), add = TRUE, col = "darkblue", lwd = 1.5)

### filter population data by buffer

#intake population data & set as sf geometry
population_raw = read_csv(here::here("data","population.csv")) |>
  janitor::clean_names() |>
  pivot_longer(cols=starts_with("x"),names_to = "year",values_to="pop") |>
  mutate(year = as.numeric(gsub("^x","",year)),
         marker_radius=scales::rescale(log10(pop+1),to=c(1,10))) |> # remove the x that janitor included for the numeric column names 
  select(-c("id","stplfips_2010"),-ends_with(c("_bing","_source"))) |>
  filter(pop!=0)

population_sf = population_raw |>
  filter(!is.na(lat) & !is.na(lon)) |>  # remove rows with missing coords
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

population_coastal <- population_sf |>
  st_join(coastline_buffer_wgs, left = FALSE) # this adds so many columns that we can reduce!

# ggplot()+
#   geom_sf(data = coastline_buffer_wgs, fill = "lightblue", color = "blue", alpha = 0.4) +
#   geom_sf(data = population_coastal, color = "red", size = 2) +
#   theme_minimal() +
#   labs(title = "Coastal Cities within 20 Miles of the US Coastline",
#        subtitle = "Buffered coastline (20 miles) and population centers",
#        caption = "Data: US boundaries, Natural Earth, and Population dataset")
#   

# save the population df so we don't have to run this each time the app loads
# coords = st_coordinates(population_coastal)

population_df <- population_coastal %>%
  mutate(lon = st_coordinates(population_coastal)[, 1],
         lat = st_coordinates(population_coastal)[, 2])
  
write_csv(population_df, here::here("data","population_coastal.csv"))
