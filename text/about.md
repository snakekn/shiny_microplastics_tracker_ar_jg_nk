## Overview of the Shiny App

The goal of this project is to explore the relationship between the population of coastal cities in the United States and plastic pollution in nearby oceans. This app provides an interactive platform to analyze this relationship and understand data limitations, using data from NOAA and the US Census Bureau.
 

### App features

US Map of all Populations & Microplastics

 - An interactive map of the United States showing plastic pollution data in the ocean and coastal city population data

Time Series: Microplastic Density by Season

  -  A time series analysis of microplastics over time by season

Linear Regression: US Map of Analyzed Populations & Microplatics

  - A linear regression analysis of the relationship between coastal city populations and localized microplastic pollution in the ocean

Kriging Analysis & Challenges

  - Kriging attempt to determine microplastic measurements in areas where there is insufficient data, and why it didn't work with this data. 

### How to Use the App

1. Select a tab to view the corresponding analysis.

2. For the US Map of all Populations & Microplastics tab

  a. Use the "Data Selection" dropdown menu to select if you want to see microplastic data and/or population data
  
3. For the Time Series: Microplastic Density by Season tab

  a. Use the "Filters" dropdown menu from the previous tab to select for different season/density/year combinations
  
  b. This will update the time series plot to show the selected data
  
4. For the Linear Regression: US Map of Analyzed Populations & Microplastics tab

  a. Read the disclosure for linear regression with this data
  
  b. Can calculate expected microplastics by population data
  
  c. Use the interactive map to see linear regressions for different cities
  
5. For the Kriging Analysis & Challenges tab

  a. Read about the attempted kriging analysis and why it didn't work with this data
  
### Units

1 m^3 = 1000 L = 35.3147 ft^3 = 1.308 yard^3 = 264.1721 gallons 


### Data Sources

This app uses plastics sampling data from NOAA and the US Census Bureau.

1. [NOAA: NCEI Marine Microplastics database](https://www.ncei.noaa.gov/products/microplastics) ([Metadata](https://data.noaa.gov/onestop/api/registry/metadata/collection/unknown/b1586022-998a-461e-b969-9d17dde6476c/raw/xml))
2. [United States Census Bureau](https://www.census.gov/data/datasets.html)

Citations:
1. National Centers for Environmental Information (NCEI). "Marine Microplastics." National Oceanic and Atmospheric Administration (NOAA), 2025, https://www.ncei.noaa.gov/products/microplastics.
2. U.S. Census Bureau. "Datasets." U.S. Census Bureau, 2025, https://www.census.gov/data/datasets.html.




