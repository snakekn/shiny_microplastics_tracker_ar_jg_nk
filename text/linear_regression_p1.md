## Attempting to conduct linear regression to explain plastic measurements using local city population

We tried conducting a linear regression to determine whether population size could help explain the level of microplastic pollution found in a region. Here are the steps we took to prepare the data:

1. Smooth out census data to create data for each year. 
2. Get a 50mi buffer for each city and filter out all microplastic data outside of that range. We also filtered for microplastic data that had a unit/m^3 measurement to have continuous data.
3.  Group data by year, so we had data points including the city's population and an average of measurements in that year.
4. Took the log10 of both population and the average measurement per year to help move the data into a more normal distribution before conducting a linear regression.

The data did not pass normality conditions, and therefore is not a good option to utilize linear regression. The data was almost heteroscedastic (p=0.058) and showed higher constance of variance (p=0.56), but the Shapiro-Wilks test showed the data was not normally distributed (p<2.2e-16). Nonetheless, we decided to move forward with allowing users to predict using the linear model. We stress the limited applications of this model.