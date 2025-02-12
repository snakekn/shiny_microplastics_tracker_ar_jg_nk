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
