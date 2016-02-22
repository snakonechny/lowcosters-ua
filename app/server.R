library(shiny)
library(dplyr)
library(ggplot2)
library(ggrepel)
library(ggmap)
library(ggthemes)

data <- read.csv('master-df.csv', header = T)

map.eu <- map_data("world")

shinyServer(function(input, output) {
  
  output$intro <- renderText({ 
    paste('For', input$country, 'there are', 
          as.numeric(data %>% filter(arr.country == input$country) %>% select(fl.num) %>% summarize(n = n())), 'weekly scheduled flights')
  })
  
  output$map <- renderPlot({
    destinations.bycountry <- data %>% filter(arr.country == input$country) %>% group_by(dep.city, dep.lat, dep.long) %>% summarize(count=n())
    origins.bycountry <- data %>% filter(arr.country == input$country) %>% group_by(arr.city, arr.lat, arr.long) %>% summarise(count=n())
    
    map <- ggplot() + 
      geom_map(map=map.eu, data=map.eu, aes(x=long, y=lat, map_id=region), color="white", fill="#7f7f7f", size=0.2, alpha=1/4) + 
      coord_map(xlim = c(-20, 45), ylim = c(62, 30)) +
      geom_point(data = destinations.bycountry, aes(x=dep.long, y=dep.lat, size = count), color = 'red') +
      labs(size = 'Number of flights') + 
      geom_point(data = origins.bycountry, aes(x=arr.long, y=arr.lat, size = count), color = 'blue') + 
      theme_pander() +
      scale_color_manual(name = "NA") +
      xlab('') +
      ylab('')
    
    print(map)
    
    if (input$mapOptions == 'cities') {
      
      map + 
      geom_text(data = destinations.bycountry, aes(x=dep.long, y=dep.lat, size = count, label = ifelse(count >= quantile(destinations.bycountry$count, .95), as.character(dep.city), '')), size = 5, vjust = .15, hjust = -.15)+
      geom_text(data = origins.bycountry, aes(x=arr.long, y=arr.lat, size = count, label = ifelse(count >= quantile(destinations.bycountry$count, .99), as.character(arr.city), '')), size = 5, vjust = -.15, hjust = -.15)

      #theme_map() +
      #theme(strip.background=element_blank())
    }
      
  })
  
  })
  

  
  
  
