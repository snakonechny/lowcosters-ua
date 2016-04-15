library(shiny)
library(shinydashboard)
library(dplyr)
library(leaflet)
library(googleVis)

countries <-  sort(c("Poland", "Hungary", "Latvia", "Czech Republic", "Romania", "Moldova", "Serbia", "Bosnia and Herzegovina", "Bulgaria", "Ukraine", "Slovakia", "Macedonia", "Lithuania", "Slovenia", "Estonia"))

#airports <- c('TZL', 'LUZ', 'WMI', 'BZG', 'LCJ', 'VNO', 'KUN', 'RIX', 'IEV', 'TAT', 'KSC', 'BTS', 'INI', 'BEG', 'SKP', 'OHD', 'KIV', 'TSR', 'TGM', 'SBZ', 'OTP', 'IAS', 'CRA', 'CLJ', 'CND', 'BRQ', 'PRG', 'OSR', 'LJU', 'DEB', 'BUD', 'VAR', 'SOF', 'PDV', 'BOJ', 'WRO', 'WAW', 'SZZ', 'RZE', 'POZ', 'KTW', 'KRK', 'GDN', 'LTN', 'TLL')
#names <- c('Sarajevo - Tuzla', 'Lublin - Lublin Intl', 'Warsaw - Modlin', 'Bydgoszcz - Ignacy Jan Paderewski Airport', 'Łódź - Władysław Reymont Airport', 'Vilnus', 'Kaunas', 'Riga', 'Kyiv - Zhuliany Intl', 'Tatry', 'Kosice', 'Bratislava - M R Stefanik', 'Nis', 'Beograd - Beograd Intl', 'Skopje', 'Ohrid', 'Chisinau - Chisinau Intl', 'Timisoara - Traian Vuia', 'Tirgu Mures - Transilvania Airport', 'Sibiu', 'Bucharest - Henri Coanda', 'Iasi', 'Craiova', 'Cluj Napoca', 'Constanta - Mihail Kogalniceanu Intl', 'Brno - Turany Intl', 'Prague - Ruzyne Intl', 'Ostrava - Mosnov Intl', 'Ljubljana', 'Debrecen', 'Budapest - Ferihegy Intl', 'Varna', 'Sofia', 'Plovdiv', 'Burgas', 'Wroclaw - Strachowice', 'Warsaw - Okecie', 'Szczecin - Goleniow', 'Rzeszow - Jasionka', 'Poznan - Lawica', 'Katowice - Pyrzowice', 'Krakow - Balice', 'Gdansk - Lech Walesa', 'London - Luton', 'Tallinn')
#names(airports) <- names


ui <- dashboardPage(
  
  dashboardHeader(title = "Lowcoster Analyzer"),
  dashboardSidebar(disable = TRUE),
  dashboardBody(
    
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
    
  fluidRow(
    tabBox('Select your analysis', id = 'maintab', height = '100%', width = '100%',
           
           tabPanel(id = 'countries', title = h4('Analyze countries'),
           
            leafletOutput('map.europe', height = 600, width = '100%'),
           
              fluidPage(style='padding-top: 60px;',
                        absolutePanel(buttom = 0, top = 150, right = 20, width = 300, draggable = TRUE, wellPanel(
                        
                        h5('Select country of origin from the dropdown below; if destinations are geographically close to each other, they will be grouped into clusters. You can change the radius around which a cluster is formed below.'),
                        selectInput('country', label = NULL, choices = countries),
                        sliderInput('radius', label = h5('Select the radius; higher number = less detailed view'), min = 1, max = 100, value = 100, step = 5),
                        h4(textOutput('intro'))
                        
              )))
  ),

  tabPanel(title = h4("Analyze airlines"), id = 'airlines', height = '100%', width = '100%',
           
            htmlOutput(outputId = "countryMap"),
            d3heatmapOutput(outputId = 'heatmap', height = 700, width = 850),
            
           
            fluidPage(style='padding-top: 60px;',
                    absolutePanel(buttom = 20, top = 140, right = 5, width = 300, draggable = TRUE, wellPanel(
                      selectInput('view', label = 'Select a metrics to track', choices = list('Flight frequency' = 1, 'Flight distribution' = 2, 'Competition' = 3)),
                      selectInput('airline', label = 'Select an airline to analyze', choices = (data %>% select(airline) %>% distinct() %>% as.list())),
                      conditionalPanel(condition = "input.view == '1'",
                      sliderInput('showTop', label = 'Select top N destinations to view', min = 2, max = 50, step = 1, value = 25))
                    ))))
)
)
)
)
           

  # tabPanel("Analyze airports")
  

#  )
#)




