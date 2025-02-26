# Purpose: Get coastal boundaries to reduce city loads
# country boundaries
countries <- ne_countries(scale = "medium", returnclass = "sf")
# filter for US 
us_boundaries <- countries |>
  filter(iso_a3 == "USA")
# land boundaries
land <- ne_download(scale = "medium", type = "land", category = "physical", returnclass = "sf")
# filter for US land boundary
us_land <- land[st_intersects(land, us_boundaries, sparse = FALSE), ]
# coastline data
coastline <- ne_download(scale = 10, type = "coastline", category = "physical", returnclass = "sf")
# filter for US coastline
us_coastline <- coastline[st_intersects(coastline, us_boundaries, sparse = FALSE), ]
# 30mi buffer around the coastline
coastline_buffer <- st_buffer(us_coastline, dist = 48280)  # 30 miles in meters
# plot buffer
plot(coastline_buffer, col = "lightblue", border = "blue", lwd = 2)
# Load the population data (cities)
population1 <- read.csv(here::here("data","population.csv")) %>%
  janitor::clean_names() %>%
  pivot_longer(cols = starts_with("x"), names_to = "year", values_to = "pop") %>%
  mutate(year = as.numeric(gsub("^x", "", year))) %>%
  select(-c("id", "stplfips_2010"), -ends_with(c("_bing", "_source"))) %>%
  filter(pop != 0)
# 