# Shiny App (ESM 244 - Advanced  Data Science)

**Team**: Alon Robbins, Justin Gutierrez, Nadav Kempinski

**Our Goal**: Understand how microplastics in our oceans are related to coastal city populations and tourism

## What it will look like

**Widget 1**: Interactive World map: Users will see a world map with microplastic data for different spots in the oceans near coastal cities. 
- Users will be able to click on those spots and see exact data for how much plastic is in that area.
- The map will have some filters that include year and season, etc..
- Specifics
-   Map: World Map, data points for coastal cities (small dots in blue) & microplastic data (size=microplastic #, opaque, colored red)
-   Data Overlay: Click on a city & see the plastic density (?) there
-   Filters: Data filters that refresh the page (year, season, type of plastic, anything else we can include from the plastics data)


**Widget 2**: Interactive world map: Users will see a world map with tourist and population of coastal cities. (can all be integrated above into one city DB)
- Users will be able to click on those cities to see exact #s for how many tourists visits per year on average, and what is the population of those cities. 
- Map will have some filters like year, season, and switching between tourists info to population info

**Widget 3**: A calculator estimate based on averages from the first two widgets (plastic debris + coastal city population/tourist info) 
- User to put in their coastal town/city #s and season/year and get an estimate of how much plastic was present or is present in the surrounding oceans
-   Calculator: User inputs city, year, season
-   Calculator can re-create model using data currently shown in the map, and filter out those that aren't being utilized currently
-   Calculator spits out LM (LR, RF?) with predictive data on estimate of plastic debris in the ocean  

**Widget 4**: allows you to graphically see trends in pollution over time by using drop downs that let you change the graph by location and time range
- This will be a line graph that shows the amount of plastic in the ocean over time for a specific location
-   User inputs location & time range
-   Graph: Line graph, x-axis = time, y-axis = plastic debris

## Our data sources
- NCEI Marine Microplastics database provides aggregated microplastic data in marine settings. (noaa_microplastics.csv): https://www.ncei.noaa.gov/products/microplastics
-   File Identifier: gov.noaa.ncei:MicroplasticsDatabase (no DOI avaiable)
-   Metadata (XML): https://data.noaa.gov/onestop/api/registry/metadata/collection/unknown/b1586022-998a-461e-b969-9d17dde6476c/raw/xml

- UN Population Division Dataset (): https://population.un.org/dataportal/home?df=1214c450-7094-471b-9b36-f0a228414cd5
-   What info do we want to consider? https://population.un.org/wpp/downloads?folder=Standard%20Projections&group=CSV%20format


- UN Tourism database (unwta_tourism.xlsx): https://www.unwto.org/tourism-statistics/key-tourism-statistics
-   Metadata inside the data folder (unwto_tourism_meta.pdf) -- huge pdf so get searching!

- We may still need to look for more plastic data or if we want to pivot from plastic carbon emission data.
