## Attempting a time series analysis of the microplastics data

We attempted to see if there was a trend or seasonality component of the microplastics data which could help predict future microplastic densities near coastal cities. 

Doing this required several steps:

1. Preparing the microplastics data. We accessed data from NCEI on microplastic samples and added spatial features to the dataset. We limited the data to those within a bounding box near the US, so we could focus on our local oceans. 
2. Filtering the pollution data. We allowed the user to select their own data, so we filter based on the user's current map view, along with their filters for season, year, and density class (discrete levels from "Very Low" to "Very High"). We also filtered for data points measured in pieces per meter cubed. 
3. Our data included gaps in measurements, and too many measurements per area for a given day. To prepare the data into time series format (in R, a "tsibble"), we aggregated data by year-month and density class, then found the monthly average density measurement. 
4. We graphed average measurements across time and per-season for each density class, which helped the user see if there are any trends or seasonality in the data.

Our next step was to model the changes in measurements to get a quantitative understanding of the trend and seasonality, but the NCEI data was not sufficient for running a model using ETS or ARIMA time modeling methods. Because the data was sporadically sampled (and not sampled in a uniform manner in areas), neither method had substantive information to run a time series analysis.

If scientists interested in oceans or pollution modeling are interested in determining a time series analysis of microplastics density in a region, we recommend designing a consistent study to sample microplastics in a specific area. Citizen scientists, academic researchers, and non-profit organizations can all play a part in the development of this database. 

The Global Partnership on Marine Litter (GPML) is a key contributor to maintaining the NCEI dataset on marine microplastics pollution, and we hope they and their data collectors input data using a uniform time distribution in the future. 