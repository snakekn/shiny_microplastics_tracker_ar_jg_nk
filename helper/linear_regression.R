## Goal: Get plastic estimate using population size
# Note: R^2 is super low and this is a poor measure of the variance seen in the data
# Data taken from cities_analysis.R work

cities_lr_log = read_csv(here::here("data","cities_lr_log.csv"))
# make LR
lr = lm(data=cities_lr_log, log_m ~ log_p) # R^2 = .0066, p-val = 1.1e-7

# plot to include in the disclaimer
ggplot(cities_lr_log, aes(x = log_p, y = log_m)) +
  geom_point(color = "steelblue", alpha = 0.6) +   # scatter plot
  geom_smooth(method = "lm", se = FALSE, color = "darkred") +  # regression line with CI
  labs(
    title = "Linear Regression of Sampled Microplastics using Population",
    x = "log10(Population)",
    y = "log(Microplastic Count)"
  ) +
  theme_minimal()

# get density_classes
microplastic_densities = read_csv(here::here("data","microplastics.csv")) |>
  filter(unit == "pieces/m3")

# commented out because there are overlaps and gaps. The one below fixes those issues
# density_ranges = microplastic_densities |>
#   select(measurement, density_class) |>
#   group_by(density_class) |>
#   summarize(min = min(measurement),
#             max = max(measurement), .groups = "drop")

density_ranges <- data.frame(
  density_class = c("Very Low", "Low", "Medium", "High", "Very High"),
  min_range = c(0.000000, 0.001000, 0.005000, 1.093829, 10.300000),
  max_range = c(0.000999, 0.004999, 1.093828, 10.29999, 7000.000000)
)

get_plastic_estimate = function(new_pop) {
  # get new microplastic estimate based on new_pop
  new_data = data.frame(log_p=log10(new_pop))
  log_m_estimate <- predict(lr, newdata = new_data)
  estimate = 10^(log_m_estimate-1)
  density = density_ranges |>
    filter(min_range <= estimate & max_range >= estimate)
  r = data.frame(d = density$density_class, e = estimate)
  return(r)
}

## Get LR per city to show off in the app
city_models <- readRDS(here::here("data", "city_models.rds"))
city = "Boston, MA"
get_city_lr = function(city) {
  # get the entire model
  city_model = city_models |>
    filter(city_st == city)
  
  if(nrow(city_model)<1) { return(NULL) }
  # View(city_model)
  
  # get the underlying data
  data = city_model |>
    unnest(data) |>
    select(1:5)
  # get the LR tidied values
  lm = city_model |>
    unnest(tidied) |>
    select(1,4:8)
  # get the analysis values
  outcome = city_model |>
    unnest(glanced) |>
    select(1,4:17)
  
  return(data)
}
