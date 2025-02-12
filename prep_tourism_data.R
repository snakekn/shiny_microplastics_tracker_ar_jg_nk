## An R script to prepare the tourism data 

## currently doesn't work :) look at cleaned_tourism_data.csv

library(readxl)
library(dplyr)
library(tidyr)
library(here)
library(tidyverse)

# Load Excel file
file_path <- here("data","unwto_tourism.xlsx")
data <- read_excel(file_path, sheet = 1, col_names = FALSE)  # Adjust sheet number if needed

# Find rows with country names (bolded in Excel, but we'll assume a pattern)
country_rows <- which(grepl("^[A-Z]+$", data[[1]], ignore.case = FALSE))

# Prepare an empty dataframe
extracted_data <- data.frame(Country = character(), Year = integer(), Tourist_Arrivals = integer(), stringsAsFactors = FALSE)

# Loop through all detected countries
for (i in seq_along(country_rows)) {
  country <- data[country_rows[i], 1]  # Extract country name
  
  # Identify the "Total" row (assumed to be the next row)
  total_row <- country_rows[i] + 1
  
  # Extract the year columns (from column 6 onwards)
  year_values <- as.numeric(data[total_row, 6:ncol(data)])
  years <- as.numeric(data[4, 6:ncol(data)])  # Assuming row 4 contains years
  
  # Store results in a dataframe
  country_df <- data.frame(Country = country, Year = years, Tourist_Arrivals = year_values)
  
  # Append to extracted data
  extracted_data <- bind_rows(extracted_data, country_df)
}

# View the formatted data
print(extracted_data)

# Save as CSV
write.csv(extracted_data, here("data","cleaned_tourism_data.csv"), row.names = FALSE)
