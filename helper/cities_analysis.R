## Goal: Get data for 20 cities ready for analysis
# Note: "Kailua, HI", has differing population sizes for the same year, so it must be manually removed

# 19 selected cities
cities <- c("Seattle, WA", "Bandon, OR", "San Francisco, CA",
            "San Diego, CA", "Panama City, FL", "Miami, FL", "Jacksonville, FL", 
            "Savannah, GA", "Charleston, SC", "Myrtle Beach, SC", "Virginia Beach, VA", 
            "Boston, MA", "Portland, ME")

city_unknown = c("Corpus Christi, TX", "Houston, TX","New Orleans, LA")

cities_known = data.frame(
  city = cities,
  known = 1
)
cities_unknown = data.frame(
  city = city_unknown,
  known = 0
)
# get all cities, known and unknown, into one dataframe. This helps us color them differently and call them differently on the map
## Note that this isn't finished!
cities_all = rbind(cities_known, cities_unknown)

## get population data without any time gaps
population_no_gaps = population |> # main population dataframe
  arrange(year) |>
  distinct(city_st, year, pop) |>
  filter(city_st != "Kailua, HI") |>
  # filter(city_st %in% cities) |>  
  as_tsibble(key=city_st, index=year)

## check for gaps - was helpful before, 19 cities were all chosen without gaps
# get where there are time gaps -- let's skip these areas
gaps = has_gaps(population_no_gaps)

# filter out the gaps
population_ts = population_no_gaps |>
  inner_join(gaps, by="city_st") |>
  filter(.gaps==FALSE) |> # shouldn't have any
  select(-.gaps)

# get city geo data
pop_map_helper = population |>
  select(city_st, geometry, marker_radius) |>
  group_by(city_st, geometry) |>
  summarize(marker = max(marker_radius), .groups="drop")

# merge cities with geolocation data
population_map = population_ts |>
  inner_join(pop_map_helper, by="city_st") |>
  as_tsibble(key=city_st, index=year) |>
  mutate(geometry = str_remove_all(geometry, "c\\(|\\)"),  # remove 'c(' and ')'
         lat = as.numeric(str_split_fixed(geometry, ",",2)[,2]),
         lon = as.numeric(str_split_fixed(geometry, ",",2)[,1]))

## save the current work and make it easy to get again
write_csv(population_map, here::here("data", "city_analysis.csv"))
population_map = read_csv(here::here("data","city_analysis.csv"))

## get microplastics for those 19 cities

# Convert city coordinates to sf object
cities_sf <- population_unique %>%
  # filter(city_st %in% cities) %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

# Create a 10-mile buffer around each city (10 miles = 16093.4 meters)
city_buffers <- st_buffer(cities_sf, dist = 160934)  # 100 miles in meters

# Convert microplastics data to sf object
microplastics_sf <- microplastics %>%
  filter(unit=="pieces/m3") |> # let's only focus on our quantitative measurement data
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

# Find microplastic points within the city buffers
microplastics_in_buffers <- st_intersection(microplastics_sf, city_buffers) |>
  distinct(measurement,date,geometry)

microplastics_in_buffers = microplastics_in_buffers |> # currently skipping over the city buffer to show all data points
  mutate(lon = st_coordinates(microplastics_in_buffers)[,1],
         lat = st_coordinates(microplastics_in_buffers)[,2],
         city_st = str_trim(city_st))

## save data!
# write_csv(microplastics_in_buffers, here::here("data", "city_microplastic2.csv"))
# microplastics_in_buffers = read_csv(here::here("data", "city_microplastic.csv"))
microplastics_in_buffers = read_csv(here::here("data", "city_microplastic2.csv"))

# use the get_city_trend function to get pop data for every year
cities_fit_pop = purrr::map_dfr(unique(population_map$city_st), get_city_trend)
write_csv(cities_fit_pop, here::here("data", "cities_fit_pop.csv"))
cities_fit_pop = read_csv(here::here("data","cities_fit_pop.csv"))


## combine microplastics and population data to get a match of population and plastics (by year) to LR
# get city data

cities_lr = microplastics_in_buffers |>
  select(measurement, date, year, city_st, geometry) |>
  mutate(year = year(date)) |>
  left_join(cities_fit_pop, by=c("city_st", "year")) |>
  drop_na() |>
  group_by(city_st, year, pop) |>
  summarize(avg_m = mean(measurement), .groups = "drop")

# get measurement estimate using lr
cities_lr_log = cities_lr_log |>
  mutate(measurement_est = predict(lr))

# write_csv(cities_lr_log, here::here("data", "cities_lr_log.csv"))


### exploratory work to see distribution and whether we have normal data for the linear regression

gg = ggplot(data=cities_lr, aes(x=pop,y=measurement,color=city_st))+
  geom_point()
plotly::ggplotly(gg)

cities_lr_log = cities_lr |>
  select(avg_m, pop, city_st) |>
  mutate(log_p = log10(pop+1),
         log_m = log10(avg_m+1)+1)

gg_log_p = ggplot(data=cities_lr_log, aes(x=log_p,y=avg_m))+
  geom_point()+
  labs(x="Log(Population)",y="Average Yearly Plastic Measurement (units/m^3)",title="Distribution of Microplastics Based on Population")+
  theme_bw()
gg_log_p

gg_log_all = ggplot(data=cities_lr_log, aes(x=log_p,y=log_m))+
  geom_point()+
  labs(x="Log(Population)",y="Log[Average Yearly Plastic Measurement (units/m^3)]")+
  theme_bw()
gg_all = (gg_log_p / gg_log_all)
gg_all
plotly::ggplotly(gg2)

# check assumptions for linear regression on cities_lr_log
# check for normality
MASS::boxcox(data=cities_lr_log, log_m ~ log_p, lambda = seq(-2, 2, 0.1))

bptest(lr)
# bpTest: p=.513
plot(lr,which=1)
car::ncvTest(lr)
# ncvTest: p = .0039
shapiro.test(residuals(lr))
# Shapiro: p<2.2e-16
plot(lr, which=2)

lm1 = lm(data = cities_lr_log, m_inv ~ log_p)
lm2 = lm(data = cities_lr_log, measurement ~ log_p)
par(mfrow = c(2,2))
plot(lm1)
plot(lm2)
rlm = MASS::rlm(data = cities_lr_log, log_m ~ log_p)
summary(rlm)
plot(rlm)