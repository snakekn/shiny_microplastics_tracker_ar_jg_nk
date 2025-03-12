# Purpose: Prepare microplastics_raw.csv data so we don't rerun the same changes each time
# Output: microplastics df

# input and mutate
microplastics <- read_csv(here::here("data","microplastics_raw.csv")) |> # still needs to have non-USA data removed
  janitor::clean_names() |>
  select(-c("doi","organization","keywords","x","y"),-starts_with("accession"),-ends_with(c("reference", "id"))) |>
  rename(lat=latitude, lon=longitude) |>
  mutate(date = as.Date(date, format = "%m/%d/%Y %I:%M:%S %p"),
         season = case_when(
           month(date) %in% 3:5 ~ "Spring",
           month(date) %in% 6:8 ~ "Summer",
           month(date) %in% 9:11 ~ "Fall",
           TRUE ~ "Winter"
         ),
         year = year(date),
         density_class=factor(density_class,ordered=TRUE,levels=c("Very Low","Low","Medium","High","Very High")),
         density_range=as.factor(density_range),
         unit=as.factor(unit),
         oceans=as.factor(oceans),
         density_marker_size = scales::rescale(as.numeric(density_class), to = c(3, 10))
  )

us_microplastics =  microplastics |>
  filter(lat>=20 & lat<=80 & lon>=-150 & lon<=-85)

# save the file
write_csv(us_microplastics,here::here("data","microplastics.csv"))