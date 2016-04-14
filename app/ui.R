library(shiny)
library(shinydashboard)
library(dplyr)
library(leaflet)

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

  tabPanel(title = h4("Analyze airlines"),
         id = 'airlines', height = '100%', width = '100%',
            fluidPage(style='padding-top: 60px;',
                    absolutePanel(buttom = 20, top = 80, right = 20, width = 300, draggable = TRUE, wellPanel(
                      selectInput('airline', label = 'Select an airline to analyze', choices = (data %>% select(airline) %>% distinct() %>% as.list())),
                      selectInput('view', label = 'Select a metrics to track', choices = list('Flight frequency', 'Flight distribution', 'Competition')),
                      checkboxInput(inputId = 'marketType', label = 'View by foreign/domestic', value = FALSE, width = '400px')
                    ))))
)
)
)
)
           

  # tabPanel("Analyze airports")
  

#  )
#)




