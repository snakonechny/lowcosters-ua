library(shiny)

master.df <- read.csv('master-df.csv', header = T)

countries <-  sort(c("Poland", "Hungary", "Latvia", "Czech Republic", "Romania", "Moldova", "Serbia", "Bosnia & Herzegovina", "Bulgaria", "Ukraine", "Slovakia", "Macedonia", "Lithuania", "Slovenia", "Estonia"))

#airports <- c('TZL', 'LUZ', 'WMI', 'BZG', 'LCJ', 'VNO', 'KUN', 'RIX', 'IEV', 'TAT', 'KSC', 'BTS', 'INI', 'BEG', 'SKP', 'OHD', 'KIV', 'TSR', 'TGM', 'SBZ', 'OTP', 'IAS', 'CRA', 'CLJ', 'CND', 'BRQ', 'PRG', 'OSR', 'LJU', 'DEB', 'BUD', 'VAR', 'SOF', 'PDV', 'BOJ', 'WRO', 'WAW', 'SZZ', 'RZE', 'POZ', 'KTW', 'KRK', 'GDN', 'LTN', 'TLL')
#names <- c('Sarajevo - Tuzla', 'Lublin - Lublin Intl', 'Warsaw - Modlin', 'Bydgoszcz - Ignacy Jan Paderewski Airport', 'Łódź - Władysław Reymont Airport', 'Vilnus', 'Kaunas', 'Riga', 'Kyiv - Zhuliany Intl', 'Tatry', 'Kosice', 'Bratislava - M R Stefanik', 'Nis', 'Beograd - Beograd Intl', 'Skopje', 'Ohrid', 'Chisinau - Chisinau Intl', 'Timisoara - Traian Vuia', 'Tirgu Mures - Transilvania Airport', 'Sibiu', 'Bucharest - Henri Coanda', 'Iasi', 'Craiova', 'Cluj Napoca', 'Constanta - Mihail Kogalniceanu Intl', 'Brno - Turany Intl', 'Prague - Ruzyne Intl', 'Ostrava - Mosnov Intl', 'Ljubljana', 'Debrecen', 'Budapest - Ferihegy Intl', 'Varna', 'Sofia', 'Plovdiv', 'Burgas', 'Wroclaw - Strachowice', 'Warsaw - Okecie', 'Szczecin - Goleniow', 'Rzeszow - Jasionka', 'Poznan - Lawica', 'Katowice - Pyrzowice', 'Krakow - Balice', 'Gdansk - Lech Walesa', 'London - Luton', 'Tallinn')
#names(airports) <- names


shinyUI(navbarPage("I'd like to",
  tabPanel("Analyze countries",
           
          sidebarPanel(
           
            selectInput('country', label = 'Select the country you would like to look at', 
                           choices = countries),
  
            sliderInput('day.range', 'How many days would you like to look at?', min = 1, max = 7, value = c(0,7)),
            helpText('Please note that 1 represents Monday, 2 - Tuesday, etc.')
          ),
          
            mainPanel(
           textOutput("country"))
          
  ),
  
  
  tabPanel("Analyze airlines"),
  tabPanel("Analyze airports")
  

  )
)




