library(shiny)
library(dplyr)
library(googleVis)
library(leaflet)
library(d3heatmap)
library(googleVis)

data <- read.csv('master-flights.csv', header = T)

#do a bit of formatting

data$date <- as.Date(data$date, format = ('%Y-%m-%d'))
data$day <- format(data$date, '%A')


shinyServer(function(input, output) {
  
  output$intro <- renderText({ 
    paste('For', input$country, 'there are', 
          as.numeric(data %>% filter(dest.country == input$country) %>% select(flight) %>% summarize(n = n())), 'weekly scheduled flights')
  })
  
  output$map.europe <- renderLeaflet({
    destinations.bycountry <- data %>% filter(dest.country == input$country) %>% group_by(origin.name, origin.city, origin.lat, origin.long) %>% summarize(count=n())
    origins.bycountry <- data %>% filter(dest.country == input$country) %>% group_by(dest.name, dest.city, dest.lat, dest.long) %>% summarize(count=n())
    
    destPal <- colorNumeric(c('#ffe559', '#dd4747'), destinations.bycountry$count)

    #function for coloring airport clusters credited to http://stackoverflow.com/questions/33600021/leaflet-for-r-how-to-customize-the-coloring-of-clusters
    leaflet(data = destinations.bycountry) %>% addTiles() %>% setView(lat = 48.438186, lng = 22.972389, zoom = 4) %>% 
      addCircleMarkers(lng = ~origin.long, lat = ~origin.lat, radius = 8, color = ~destPal(count), stroke = FALSE, fillOpacity = .8, popup = ~as.character(paste(origin.name, 'Airport in', origin.city, 'receives', count, 'flights weekly from', input$country, sep = ' ')), clusterOptions = markerClusterOptions(maxClusterRadius = input$radius, 
      iconCreateFunction=JS("function (cluster) {    
      var childCount = cluster.getChildCount(); 
      var c = ' marker-cluster-';  
      if (childCount < 100) {  
      c += 'large';  
      } else if (childCount < 1000) {  
      c += 'medium';  
      } else { 
      c += 'small';  
      }    
      return new L.DivIcon({ html: '<div><span>' + childCount + '</span></div>', className: 'marker-cluster' + c, iconSize: new L.Point(40, 40) });
      }"))) %>%
      addCircleMarkers(data = origins.bycountry, lng = ~dest.long, lat = ~dest.lat, radius = 8, color = '#2f576e', stroke = FALSE, fillOpacity = .8, popup = ~as.character(paste(count, 'weekly flights originate from', dest.city, 'in', input$country)), clusterOptions = markerClusterOptions(maxClusterRadius = 5)) %>%
      addLegend('bottomright', pal = destPal, values = ~count, title = 'Number of arrivals') %>%
      #addLegend('bottomleft', pal = originPal, values = origins.bycountry$count, title = 'Number of departures', labFormat = labelFormat()) %>%
      addProviderTiles('CartoDB.Positron')
      
  })
  
    
  output$heatmap <- renderD3heatmap({
    
    if (input$view == 1) {
      
    matrixDest <- data %>% filter(airline == input$airline) %>% group_by(day, dest.name) %>% summarize(n = n()) %>% spread(day, n) %>% mutate(total = rowSums(.[, 2:8])) %>% arrange(desc(total)) %>% slice(1:input$showTop)
    matrixDest <- matrixDest[c('dest.name','Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')]
    rownames(matrixDest) <- matrixDest$dest.name
    matrixDest$dest.name <- NULL
    d3heatmap(matrixDest, dendrogram = 'none', colors = scales::col_bin('Oranges', domain = NULL, bins = 10), scale = 'column')

    }
  })
  
  output$countryMap <- renderGvis({
    
    if (input$view == 2) {
    
    countryData <- data %>% filter(airline == input$airline) %>% group_by(dest.country) %>% summarise(Flights = n()) 
    gvisGeoChart(countryData, 'dest.country', colorvar = 'Flights', options = list(region = '150', height = 700, width = 850))
      
    }
  })
  
  
  })


  

  
