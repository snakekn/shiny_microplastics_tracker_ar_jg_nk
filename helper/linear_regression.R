## Goal: Get plastic estimate using population size
# Note: R^2 is super low and this is a poor measure of the variance seen in the data
# Data taken from cities_analysis.R work

cities_lr_log = read_csv(here::here("data","cities_lr_log.csv"))
# make LR
lr = lm(data=cities_lr_log, log_m ~ log_p) # R^2 = .0066, p-val = 1.1e-7

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
