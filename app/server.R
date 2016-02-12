library(shiny)
library(dplyr)

data <- read.csv('master-df.csv', header = T)

shinyServer(function(input, output) {
  
  output$country <- renderText({ 
    paste('You have selected', input$country, 'for this analysis')
  })
    
  })
  

  
  
  
