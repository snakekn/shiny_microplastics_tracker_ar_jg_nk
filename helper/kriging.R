# Purpose: Kriging 

# move libraries into global.R when you're done!
library(gstat)
library(sp)


# pull in prepped microplastics data
microplastics = read_csv(here::here("data","microplastics.csv"))

microplastics_clean <- microplastics_data_sf |>
  filter(unit == "pieces/m3") |> 
  st_transform(crs = 4326)
  

# 5. Define the bounding box and grid size for each region
regions <- list(
  Tampa = list(lon = c(-83, -81), lat = c(27, 29), grid_size = 1000), # 1km grid
  BayArea = list(lon = c(-124, -121), lat = c(36, 39), grid_size = 2000), # 2km grid
  NewEngland = list(lon = c(-72, -66), lat = c(41, 45), grid_size = 3000), # 3km grid
  Miami = list(lon = c(-81.5, -79.5), lat = c(25, 27), grid_size = 1000), # 1km grid
  PugetSound = list(lon = c(-123.5, -122), lat = c(47.0, 48.5), grid_size = 1000), # 1km grid
  AtlanticOcean = list(lon = c(-77, -64), lat = c(24, 40), grid_size = 10000) # 10km grid
)

plot_variogram_for_region <- function(region_name, region_data, microplastics_clean) {
  # Extract the bounding box coordinates
  lon_min <- region_data$lon[1]
  lon_max <- region_data$lon[2]
  lat_min <- region_data$lat[1]
  lat_max <- region_data$lat[2]
  
  # Create a bounding box from the region
  region_bbox <- st_bbox(c(
    xmin = lon_min, xmax = lon_max,
    ymin = lat_min, ymax = lat_max
  ), crs = st_crs(microplastics_clean))  # Ensure CRS consistency
  
  # Check if the bounding box is valid
  if (any(is.na(region_bbox))) {
    stop("Invalid bounding box for region: ", region_name)
  }
  
  # Subset the data based on the region's bounding box
  region_data_sf <- microplastics_clean %>%
    st_filter(st_as_sfc(region_bbox))
  
  # Compute variogram
  region_vgm <- gstat::variogram(measurement ~ 1, data = region_data_sf)
  
  # Plot the variogram
  plot(region_vgm, main = paste("Variogram for", region_name))
}

# Apply the function to each region
lapply(names(regions), function(region_name) {
  plot_variogram_for_region(region_name, regions[[region_name]], microplastics_clean)
})




for (region_name in names(regions)) {
  region <- regions[[region_name]]
  
  # 6.1. Create the prediction grid based on the bounding box and grid size
  grid <- expand.grid(lon = seq(region$lon[1], region$lon[2], by = region$grid_size),
                      lat = seq(region$lat[1], region$lat[2], by = region$grid_size))
  
  # 6.2. Convert grid to spatial object (sf object)
  grid_sf <- st_as_sf(grid, coords = c("lon", "lat"), crs = 4326)  # Assuming CRS is 4326 for global lat/lon
  
  # 6.3. Create an sf object for the region's bounding box (a polygon around the region)
  region_bbox <- st_sfc(st_polygon(list(matrix(c(region$lon[1], region$lat[1],  # bottom-left corner
                                                 region$lon[2], region$lat[1],  # bottom-right corner
                                                 region$lon[2], region$lat[2],  # top-right corner
                                                 region$lon[1], region$lat[2],  # top-left corner
                                                 region$lon[1], region$lat[1]),  # close the loop
                                               ncol = 2, byrow = TRUE))))
  st_crs(region_bbox) <- 4326  # Ensure the CRS is 4326
  
  # 6.4. Subset the microplastics data for the current region's bounding box using geometry
  region_data <- microplastics_clean %>%
    st_intersection(region_bbox)  # Use spatial intersection to filter by bounding box
  
  # Ensure CRS is consistent across region_data and grid_sf
  region_data <- st_transform(region_data, crs = st_crs(grid_sf))
  
  # 6.5. Convert region_data to data.frame and extract coordinates
  region_df <- st_as_sf(region_data)  # Convert to sf object if necessary
  region_df_coords <- st_coordinates(region_df)  # Extract coordinates (longitude and latitude)
  
  # Add coordinates to the data frame
  region_df$lon <- region_df_coords[, 1]
  region_df$lat <- region_df_coords[, 2]
  
  # 6.6. Create gstat object from the data frame (ensure measurement is a numeric variable)
  region_df$measurement <- as.numeric(region_df$measurement)  # Ensure 'measurement' is numeric
  
  # Convert sf object to SpatialPointsDataFrame
  region_spdf <- as(region_df, "Spatial")  # Convert to SpatialPointsDataFrame for kriging
  
  # 6.7. Create a gstat object from the spatial data
  gstat_data <- gstat(id = "measurement", formula = measurement ~ 1, data = region_spdf)
  
  # 6.8. Compute the variogram (using 'measurement' as the variable)
  region_vgm <- gstat::variogram(gstat_data)
  
  # 6.9. Fit a variogram model with adjusted parameters if needed
  fitted_model <- fit.variogram(region_vgm, model = vgm(1, "Sph", 1000, 1))  # Adjust model if necessary
  
  # 6.10. Perform kriging (interpolation) using the fitted model
  krige_result <- gstat::krige(measurement ~ 1, data = region_spdf, newdata = grid_sf, model = fitted_model)
  
  # 6.11. Convert kriging result into SpatialPixelsDataFrame
  krige_spdf <- as(krige_result, "SpatialPixelsDataFrame")
  
  # 6.12. Plot the kriging result
  plot(krige_spdf, main = paste("Kriging Result for", region_name), col = heat.colors(100))
  
  # 6.13. Optionally, save the output to a file (e.g., GeoTIFF, CSV, etc.)
  # writeRaster(krige_spdf, filename = paste0("krige_result_", region_name, ".tif"), format = "GTiff")
}












# Split the data into Pacific and Atlantic
microplastics_data_sf <- st_as_sf(microplastics, coords = c("lon", "lat"), crs = 4326)|>
  mutate(density_numeric = case_when(
    density_class == "Very Low" ~ 1,
    density_class == "Low" ~ 2,
    density_class == "Medium" ~ 3,
    density_class == "High" ~ 4,
    density_class == "Very High" ~ 5))

#Split Pacific and Atlantic 
us_pacific_data <- microplastics_data_sf %>% filter(oceans == "Pacific Ocean")|>
  st_transform(crs = 32611)

## get US coastlines so we can see what we're dealing with here
# project before buffering
us_coast_proj = st_transform(us_coastline,crs=5070) # us_coastline is from coastal_buffer.R!

# get 30mi buffer
coastline_buffer <- st_buffer(us_coast_proj, dist = 16e6)  # ~1K miles in meters

# back to our krig method
coastline_buffer_32611 = st_transform(coastline_buffer,crs=32611)

# let's see if this shows us the US-based Pacific microplastics data, yep!
ggplot()+
  geom_sf(data=us_coast_proj,color="red", size=2) +
  # geom_sf(data=coastline_buffer_32611,color="lightpink", size=2) +
  geom_sf(data = us_pacific_data, fill = "lightblue", color = "blue", alpha = 0.4)
  
  theme_minimal() +
  labs(title = "Coastal Cities within 20 Miles of the US Coastline",
       subtitle = "Buffered coastline (20 miles) and population centers",
       caption = "Data: US boundaries, Natural Earth, and Population dataset")


atlantic_data <- microplastics_data_sf %>% filter(oceans == "Atlantic Ocean") 
arctic_data = microplastics_data_sf %>% filter(oceans == "Arctic Ocean")
southern_data = microplastics_data_sf %>% filter(oceans == "Southern Ocean")
na_ocean_data = microplastics_data_sf %>% filter(is.na(oceans)) # all freshwater(?) analysis in the US

# Split Atlantic data into Gulf of Mexico and Other regions
gulf_of_mexico_data <- atlantic_data %>% filter(regions == "Gulf of Mexico")
other_atlantic_data <- atlantic_data %>% filter(regions != "Gulf of Mexico")

# View locations of data around the world, looks good around the US!
ggplot() +
  geom_sf(data=us_coast_proj,color="red", size=2) +
  geom_sf(data = us_pacific_data, fill = "lightblue", color = "blue", alpha = 0.4)+
  geom_sf(data = atlantic_data, fill = "lightblue", color = "blue", alpha = 0.4)+
  geom_sf(data = southern_data, fill = "lightblue", color = "blue", alpha = 0.4)+
  geom_sf(data = na_ocean_data, fill = "lightblue", color = "blue", alpha = 0.4) +
  theme_minimal() +
  labs(title = "Plastic Pollution within a bounding box near the US")

# Variogram for Pacific Ocean
pacific_vgm <- variogram(density_numeric ~ 1, data = us_pacific_data)
pacific_vgm_fit <- fit.variogram(pacific_vgm, model = vgm(0.5, "Sph", 10000, 2))

# Plot the variogram for Pacific Ocean data to inspect its structure
ggplot() + 
  geom_point(data = pacific_vgm, aes(x = dist, y = gamma)) + 
  labs(title = "Variogram for Pacific Ocean", x = "Distance", y = "Semivariance")

# Create a grid for kriging
grid_pacific <- st_bbox(us_pacific_data) %>%
  stars::st_as_stars(dx = 5000, dy = 5000)


# Kriging for Pacific Ocean
krige_pacific <- krige(density_numeric ~ 1, us_pacific_data, grid_pacific, model = pacific_vgm_fit)


# Visualize Kriging Result for Pacific
ggplot() + 
  geom_spatraster(data = krige_pacific, aes(fill = pred)) + 
  scale_fill_viridis_c() +
  ggtitle("Kriging of Microplastic Density in Pacific Ocean")



###################################




# Variogram for Other Atlantic
atlantic_vgm <- variogram(density_numeric ~ 1, data = other_atlantic_data)
atlantic_vgm_fit <- fit.variogram(atlantic_vgm, model = vgm(1, "Sph", 300, 1))


ggplot() + 
  geom_point(data = atlantic_vgm, aes(x = dist, y = gamma)) + 
  labs(title = "Variogram for Pacific Ocean", x = "Distance", y = "Semivariance")


# Create a grid for kriging
grid_atlantic <- st_bbox(other_atlantic_data) %>%
  st_as_stars(dx = 1000, dy = 1000)

# Kriging for Other Atlantic
krige_atlantic <- krige(density_numeric ~ 1, other_atlantic_data, grid_atlantic, model = atlantic_vgm_fit)

# Visualize Kriging Result for Other Atlantic
ggplot() + 
  geom_spatraster(data = krige_atlantic, aes(fill = pred)) + 
  scale_fill_viridis_c() +
  ggtitle("Kriging of Microplastic Density in Other Atlantic Regions")

# Variogram for Gulf of Mexico
gulf_vgm <- variogram(density_numeric ~ 1, data = gulf_of_mexico_data)
gulf_vgm_fit <- fit.variogram(gulf_vgm, model = vgm(1, "Sph", 300, 1))

ggplot() + 
  geom_point(data = gulf_vgm, aes(x = dist, y = gamma)) + 
  labs(title = "Variogram for Pacific Ocean", x = "Distance", y = "Semivariance")

# Create a grid for kriging
grid_gulf <- st_bbox(gulf_of_mexico_data) %>%
  st_as_stars(dx = 1000, dy = 1000)

# Kriging for Gulf of Mexico
krige_gulf <- krige(density_numeric ~ 1, gulf_of_mexico_data, grid_gulf, model = gulf_vgm_fit)

# Visualize Kriging Result for Gulf of Mexico
ggplot() + 
  geom_spatraster(data = krige_gulf, aes(fill = pred)) + 
  scale_fill_viridis_c() +
  ggtitle("Kriging of Microplastic Density in Gulf of Mexico")


# Combine all kriged results
krige_combined <- bind_rows(
  mutate(krige_pacific, region = "Pacific"),
  mutate(krige_gulf, region = "Gulf of Mexico"),
  mutate(krige_atlantic, region = "Other Atlantic")
)

# Visualize combined Kriging results
ggplot() + 
  geom_spatraster(data = krige_combined, aes(fill = pred)) + 
  scale_fill_viridis_c() +
  facet_wrap(~region) +
  ggtitle("Combined Kriging of Microplastic Density")






