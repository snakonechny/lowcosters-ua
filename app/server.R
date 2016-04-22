library(shiny)
library(dplyr)
library(tidyr)
library(googleVis)
library(leaflet)
library(d3heatmap)
library(googleVis)

data <- read.csv('master-flights.csv', header = T)

#do a bit of formatting

data$date <- as.Date(data$date, format = ('%Y-%m-%d'))
data$day <- format(data$date, '%A')

#standardize Milan as "Milano"
data$origin.city[data$origin.city == 'Milan'] <- 'Milano'
data$dest.city[data$dest.city == 'Milan'] <- 'Milano'

#compute a "reference dictionary of airlines' operations
#destAirline.count <- data %>% group_by(dest.city, airline) %>% summarize(n = n()) %>% spread(airline, n) %>% ungroup() %>% mutate(airlines = apply(.[,2:8], 1, function(x) sum(!(is.na(x)))), totalFlights = rowSums(.[,2:8], na.rm = TRUE)) %>% select(1, 9:10)



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
      
    matrixDest <- data %>% filter(airline == input$airline) %>% group_by(day, dest.city) %>% summarize(n = n()) %>% spread(day, n) %>% mutate(total = rowSums(.[, 2:8])) %>% arrange(desc(total)) %>% slice(1:input$showTop)
    matrixDest <- matrixDest[c('dest.city','Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')]
    rownames(matrixDest) <- matrixDest$dest.city
    matrixDest$dest.city <- NULL
    d3heatmap(matrixDest, dendrogram = 'none', colors = scales::col_bin('Oranges', domain = NULL, bins = 10), scale = 'column')

    }
  })
  
  output$countryMap <- renderGvis({
    
    if (input$view == 2) {
    
    countryData <- data %>% filter(airline == input$airline) %>% group_by(dest.country) %>% summarise(Flights = n()) %>% mutate(Percentage = round(.$Flights/sum(.$Flights, na.rm = FALSE)*100, digits = 2)) 
    gvisGeoChart(countryData, locationvar = 'dest.country', colorvar = 'Flights', hovervar = 'dest.country', sizevar = 'Percentage', options = list(region = '150', height = 450, width = 500))
    }})
  
  output$sankey <- renderGvis({
    
    if (input$view == 2) {
    
    cityPairs <- data %>% filter(airline == input$airline) %>% select(origin.city, dest.city) %>% data.frame(t(apply(., 1, sort))) %>% select(X1, X2) %>% group_by(X1, X2) %>% summarise(Flights = n()) %>% ungroup() %>% arrange(desc(Flights)) %>% slice(1:10)
    gvisSankey(cityPairs, from = 'X1', to = 'X2', weight = 'Flights', options = list(height = 450, width = 400, sankey = "{node: {nodePadding: '25'}}, {link: {color: {fillOpacity: '.5'}}}"))
    
    }})
  
  output$treeMap <- renderGvis({
    
    if (input$view == 3) {
    
    destAirline.count <- data %>% group_by(dest.city, airline) %>% summarize(n = n()) %>% spread(airline, n) %>% ungroup() %>% mutate(airlines = apply(.[,2:8], 1, function(x) sum(!(is.na(x)))), totalFlights = rowSums(.[,2:8], na.rm = TRUE)) %>% select(1, 9:10)
      
    compCity <- data %>% filter(airline == input$airline) %>% group_by(dest.city) %>% summarise(flights = n())
      
    #match the compCity df with the master list of airports
    compCity <<- left_join(destAirline.count, compCity) %>% filter(complete.cases(.))
      
    compCity$category[compCity$airlines == 1] <- 'One airline'
    compCity$category[compCity$airlines == 2] <- 'Two airlines'
    compCity$category[compCity$airlines == 3] <- 'Three airlines'
    compCity$category[compCity$airlines == 4] <- 'Four airlines'
    compCity$category[compCity$airlines == 5] <- 'Five airlines'
    compCity$category[compCity$airlines == 6] <- 'Six airlines'
    compCity$category[compCity$airlines == 7] <- 'Seven airlines'
      
    
    totals <<- data.frame(dest.city = 'All cities', airlines = 6, totalFlights = sum(compCity$totalFlights), flights = sum(compCity$flights), category = NA)
    totals$dest.city <<- as.character(totals$dest.city)
    totals.parents <<- compCity %>% group_by(category) %>% summarize(airlines = 7, totalFlights = sum(.$totalFlights), flights = sum(.$flights), dest.city = 'All cities') %>% select(5, 2, 3, 4, 1)
    colnames(totals.parents) <<- c('category', 'airlines', 'totalFlights', 'flights', 'dest.city')
    
    compCity <- bind_rows(compCity, totals, totals.parents)
    compCity$category[compCity$category == 'NA'] <- NA
    
    gvisTreeMap(compCity, idvar = "dest.city", parentvar = "category", sizevar = "totalFlights", colorvar = "flights", options = list(fontSize = 16, minColor = '#fff7bc', midColor = '#fec44f', maxColor = '#d95f0e', showScale = TRUE))
    
    }
    
  })
  
  })


  

  
