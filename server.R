#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)

# Goal: Understand how microplastics in our oceans are related to coastal city populations and tourism


# Data sources: 
# NCEI Marine Microplastics database provides aggregated microplastic data in marine settings. (noaa_microplastics.csv): https://www.ncei.noaa.gov/products/microplastics
### File Identifier: gov.noaa.ncei:MicroplasticsDatabase (no DOI avaiable)
### Metadata (XML): https://data.noaa.gov/onestop/api/registry/metadata/collection/unknown/b1586022-998a-461e-b969-9d17dde6476c/raw/xml

# UN Population Division Dataset (): https://population.un.org/dataportal/home?df=1214c450-7094-471b-9b36-f0a228414cd5
### - What info do we want to consider? https://population.un.org/wpp/downloads?folder=Standard%20Projections&group=CSV%20format


# - UN Tourism database (unwta_tourism.xlsx): https://www.unwto.org/tourism-statistics/key-tourism-statistics
### Metadata inside the data folder (unwto_tourism_meta.pdf) -- huge pdf so get searching!

# - We may still need to look for more plastic data or if we want to pivot from plastic carbon emission data.


# Define server logic required to draw a histogram
function(input, output, session) {
  
  output$distPlot <- renderPlot({
    
    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white',
         xlab = 'Waiting time to next eruption (in mins)',
         main = 'Histogram of waiting times')
    
  })
  
}
