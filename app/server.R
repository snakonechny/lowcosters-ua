library(shiny)
library(dplyr)
library(googleVis)
library(leaflet)

data <- read.csv('master-flights.csv', header = T)


shinyServer(function(input, output) {
  
  output$intro <- renderText({ 
    paste('For', input$country, 'there are', 
          as.numeric(data %>% filter(dest.country == input$country) %>% select(flight) %>% summarize(n = n())), 'weekly scheduled flights')
  })
  
  output$map.europe <- renderLeaflet({
    destinations.bycountry <- data %>% filter(dest.country == input$country) %>% group_by(origin.name, origin.city, origin.lat, origin.long) %>% summarize(count=n())
    origins.bycountry <- data %>% filter(dest.country == input$country) %>% group_by(dest.name, dest.city, dest.lat, dest.long) %>% summarize(count=n())
    
    destPal <- colorNumeric(c('#ffe559', '#dd4747'), destinations.bycountry$count)

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
  })
  
#map <- ggplot() + 
  #geom_map(map=map.eu, data=map.eu, aes(x=long, y=lat, map_id=region), color="white", fill="#7f7f7f", size=0.2, alpha=1/4) + 
  #coord_map(xlim = c(-20, 45), ylim = c(62, 30)) +
  #geom_point(data = destinations.bycountry, aes(x=dep.long, y=dep.lat, size = count), color = 'red') +
  #labs(size = 'Number of flights') + 
  #geom_point(data = origins.bycountry, aes(x=arr.long, y=arr.lat, size = count), color = 'blue') + 
  #theme_pander() +
  #scale_color_manual(name = "NA") +
  #xlab('') +
  #ylab('')

#print(map)
  
#if (input$mapOptions == 'cities') {
  
#  map + 
#    geom_text(data = destinations.bycountry, aes(x=dep.long, y=dep.lat, size = count, label = ifelse(count >= quantile(destinations.bycountry$count, .95), as.character(dep.city), '')), size = 5, vjust = .15, hjust = -.15)+
#    geom_text(data = origins.bycountry, aes(x=arr.long, y=arr.lat, size = count, label = ifelse(count >= quantile(destinations.bycountry$count, .99), as.character(arr.city), '')), size = 5, vjust = -.15, hjust = -.15)
  
  #theme_map() +
  #theme(strip.background=element_blank())
#}

  
