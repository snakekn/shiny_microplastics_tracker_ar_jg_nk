### Prepare tourism data with geocoded MSA data
library(tidyverse)
library(here)

tourism = read.csv(here::here("data","tourism.csv"), na.string = c("","NA","na")) |> # data needs to be reformatted
  janitor::clean_names() |>
  rename(msa = city_msa_visitation,
         pct_2023 = market,
         pct_2022 = market_1,
         visits_2023 = visitation,
         visits_2022 = visitation_1) |>
  select(-x,-rank) |>
  drop_na() |>
  mutate(pct_2023 = as.numeric(gsub("[%,]","",pct_2023))/100,
         pct_2022 = as.numeric(gsub("[%,]","",pct_2022))/100,
         visits_2023 = as.numeric(gsub("[%,]","",visits_2023))*1000,
         visits_2022 = as.numeric(gsub("[%,]","",visits_2022))*1000)

tourism_geo = tourism |>
  mutate(
    msa = gsub("\\(.*?\\)", "", msa),  # Remove parentheses and content inside
    msa = gsub(" MSA| MD", "", msa),  # Remove "MSA" and "MD"
    cities = strsplit(msa, "-")  # Split by "-"
  ) %>%
  unnest(cities) %>%  # Expand to separate rows for each city
  mutate(cities = trimws(cities)) |> # Remove leading/trailing spaces  
separate(cities, into = c("city", "state"), sep = ", ", extra = "merge", fill = "right")
  
  tidygeocoder::geocode(city = city_clean, method = "osm", lat = latitude, long = longitude)

# Save the geocoded results so it's not re-run every time
write_csv(tourism_geocoded, here::here("data", "tourism_geocoded.csv"))


