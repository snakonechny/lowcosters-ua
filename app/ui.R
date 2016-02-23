library(shiny)
library(leaflet)

countries <-  sort(c("Poland", "Hungary", "Latvia", "Czech Republic", "Romania", "Moldova", "Serbia", "Bosnia & Herzegovina", "Bulgaria", "Ukraine", "Slovakia", "Macedonia", "Lithuania", "Slovenia", "Estonia"))

#airports <- c('TZL', 'LUZ', 'WMI', 'BZG', 'LCJ', 'VNO', 'KUN', 'RIX', 'IEV', 'TAT', 'KSC', 'BTS', 'INI', 'BEG', 'SKP', 'OHD', 'KIV', 'TSR', 'TGM', 'SBZ', 'OTP', 'IAS', 'CRA', 'CLJ', 'CND', 'BRQ', 'PRG', 'OSR', 'LJU', 'DEB', 'BUD', 'VAR', 'SOF', 'PDV', 'BOJ', 'WRO', 'WAW', 'SZZ', 'RZE', 'POZ', 'KTW', 'KRK', 'GDN', 'LTN', 'TLL')
#names <- c('Sarajevo - Tuzla', 'Lublin - Lublin Intl', 'Warsaw - Modlin', 'Bydgoszcz - Ignacy Jan Paderewski Airport', 'Łódź - Władysław Reymont Airport', 'Vilnus', 'Kaunas', 'Riga', 'Kyiv - Zhuliany Intl', 'Tatry', 'Kosice', 'Bratislava - M R Stefanik', 'Nis', 'Beograd - Beograd Intl', 'Skopje', 'Ohrid', 'Chisinau - Chisinau Intl', 'Timisoara - Traian Vuia', 'Tirgu Mures - Transilvania Airport', 'Sibiu', 'Bucharest - Henri Coanda', 'Iasi', 'Craiova', 'Cluj Napoca', 'Constanta - Mihail Kogalniceanu Intl', 'Brno - Turany Intl', 'Prague - Ruzyne Intl', 'Ostrava - Mosnov Intl', 'Ljubljana', 'Debrecen', 'Budapest - Ferihegy Intl', 'Varna', 'Sofia', 'Plovdiv', 'Burgas', 'Wroclaw - Strachowice', 'Warsaw - Okecie', 'Szczecin - Goleniow', 'Rzeszow - Jasionka', 'Poznan - Lawica', 'Katowice - Pyrzowice', 'Krakow - Balice', 'Gdansk - Lech Walesa', 'London - Luton', 'Tallinn')
#names(airports) <- names


shinyUI(navbarPage("I'd like to",
  tabPanel("Analyze countries",
           
            leafletOutput('map.europe', height = 600),
           
              fluidPage(style='padding-top: 60px;',
                        absolutePanel(buttom = 20, top = 80, right = 20, width = 300, draggable = TRUE, wellPanel(
                        
                        h5('Selecting a country from the dropdown below refreshes the map; if airport-cities are geographically close to each other, they will be grouped into clusters colored in green. Click on each cluster to expand the airport markers.'),
                        selectInput('country', label = NULL, choices = countries),
                        h4(textOutput('intro'))
                        
              )
                        )
              )
          
  ),
  
  
  tabPanel("Analyze airlines"),
  tabPanel("Analyze airports")
  

  )
)




