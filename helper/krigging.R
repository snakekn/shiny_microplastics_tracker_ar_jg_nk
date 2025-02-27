#Krigging 

# move libraries into global.R when you're done!
library(gstat)

# Split the data into Pacific and Atlantic
microplastics_data_sf <- st_as_sf(microplastics, coords = c("lon", "lat"), crs = 4326)|>
  mutate(density_numeric = case_when(
    density_class == "Very Low" ~ 1,
    density_class == "Low" ~ 2,
    density_class == "Medium" ~ 3,
    density_class == "High" ~ 4,
    density_class == "Very High" ~ 5))

#Split Pacific and Atlantic 
pacific_data <- microplastics_data_sf %>% filter(oceans == "Pacific Ocean")
atlantic_data <- microplastics_data_sf %>% filter(oceans == "Atlantic Ocean")
arctic_data = microplastics_data_sf %>% filter(oceans == "Arctic Ocean")
southern_data = microplastics_data_sf %>% filter(oceans == "Southern Ocean")
na_ocean_data = microplastics_data_sf %>% filter(is.na(oceans)) # all freshwater(?) analysis in the US

# Split Atlantic data into Gulf of Mexico and Other regions
gulf_of_mexico_data <- atlantic_data %>% filter(regions == "Gulf of Mexico")
other_atlantic_data <- atlantic_data %>% filter(regions != "Gulf of Mexico")

# View locations of data around the world
# ggplot() + 
#   geom_sf(data=world_sf,fill=NA,color="black")+
#   geom_sf(data=_data)


# Variogram for Pacific Ocean
pacific_vgm <- variogram(density_numeric ~ 1, data = pacific_data)
pacific_vgm_fit <- fit.variogram(pacific_vgm, model = vgm(1, "Sph", 300, 1))

# Create a grid for kriging
grid_pacific <- st_bbox(pacific_data) %>%
  stars::st_as_stars(dx = 1000, dy = 1000)

# Kriging for Pacific Ocean
krige_pacific <- krige(density_numeric ~ 1, pacific_data, grid_pacific, model = pacific_vgm_fit)

# Visualize Kriging Result for Pacific
ggplot() + 
  geom_spatraster(data = krige_pacific, aes(fill = pred)) + 
  scale_fill_viridis_c() +
  ggtitle("Kriging of Microplastic Density in Pacific Ocean")

# Variogram for Other Atlantic
atlantic_vgm <- variogram(density_numeric ~ 1, data = other_atlantic_data)
atlantic_vgm_fit <- fit.variogram(atlantic_vgm, model = vgm(1, "Sph", 300, 1))

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






