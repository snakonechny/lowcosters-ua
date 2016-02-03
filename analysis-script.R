library(RJSONIO)
library(dplyr)
library(ggmap)

#read the file
flights <- read.csv('master-flights.csv', header = TRUE)
flights.w6 <- flights %>% filter(airline == 'W6') %>% select(2) %>% transmute(flight.num = substr(flight.nums.i., 3, length(flight.nums.i.))) %>% filter(as.numeric(flight.num) %% 2 != 1)
flights <- flights$flight.num

#define dates
dates <- c(11:17)
master.try <- data.frame()
master.try2 <- data.frame()

for(date in dates) {
  for (fn in flights.fr) {
    url <- paste(paste('https://api.flightstats.com/flex/schedules/rest/v1/json/flight/', fn, 'departing/2016/1', date, sep = '/'), '?appId=#f&appKey=#', sep = '')
    flight <- fromJSON(url)
    
    if (length(flight$scheduledFlights)!=0) {
    
           flight.date <- as.character(flight$request$date['interpreted'])
           flight.num <- paste(flight$scheduledFlights[[1]]$carrierFsCode, flight$scheduledFlights[[1]]$flightNumber, sep = '')
           flight.origin <- flight$scheduledFlights[[1]]$departureAirportFsCode
           flight.dest <- flight$scheduledFlights[[1]]$arrivalAirportFsCode
           flight.deptime <- flight$scheduledFlights[[1]]$departureTime
           flight.arrtime <- flight$scheduledFlights[[1]]$arrivalTime
           flight.eq <- flight$scheduledFlights[[1]]$flightEquipmentIataCode
           
           flight.data <- data.frame(flight.date, flight.num, flight.origin, flight.dest, flight.deptime, flight.arrtime, flight.eq)
           master.try2 <- bind_rows(master.try2, flight.data)
           
    }
  }
}

master.w6 <- master.try
write.csv(master.try, 'master-try.csv')

#-----#
#A slightly different exercise for Ryanair, since the flight numbers seem to shuffle around
#we'll only subset the Eastern European airports here, for brevity's sake
eastern.europe <- read.csv('eastern-dest.csv', header = TRUE) %>% .$iata

airports <- eastern.europe

dates <- (22:28)
hours <- c(0, 6, 12, 18)

#create an empty reference data set
master.fr <- data.frame()

for(airport in airports){
  for(date in dates){
    for(hour in hours){

    url <- paste(paste(paste(paste(paste('https://api.flightstats.com/flex/flightstatus/rest/v2/json/airport/status', airport, sep = '/'), 'arr/2016/1', sep = '/'), date, sep = '/'), hour, sep = '/'), '?appId=#&appKey=#&utc=false&numHours=6&carrier=FR', sep = '')
    segment <- fromJSON(url)
    
    if(length(segment$flightStatuses)!=0){
    for(i in 1:length(segment$flightStatuses)) {
      flight.date <- as.character(segment$request$date['interpreted'])
      flight.num <- paste(segment$flightStatuses[[i]]$carrierFsCode, segment$flightStatuses[[i]]$flightNumber[1], sep = '')
      flight.origin <- segment$flightStatuses[[i]]$departureAirportFsCode
      flight.dest <- segment$flightStatuses[[i]]$arrivalAirportFsCode
      flight.deptime <- as.character(segment$flightStatuses[[i]]$departureDate[1])
      flight.arrtime <- as.character(segment$flightStatuses[[i]]$arrivalDate[1])
      flight.eq <- as.character(segment$flightStatuses[[i]]$flightEquipment[1])
    
      temp <- data.frame(flight.date, flight.num, flight.origin, flight.dest, flight.deptime, flight.arrtime, flight.eq)
      master.fr <- bind_rows(master.fr, temp)
    }
      }
    }
  }
}

write.csv(master.fr, 'master-fr.csv')

#-----#
#Now combine the two datasets

master.df <- bind_rows(master.w6, master.fr)

#More data wrangling
#Format the date field correctly and figure out what day of the week the flight took place on

master.df$flight.deptime <- as.POSIXct(master.df$flight.deptime, format = '%Y-%m-%dT%H:%M:%OS')
master.df$flight.arrtime <- as.POSIXct(master.df$flight.arrtime, format = '%Y-%m-%dT%H:%M:%OS')
master.df$weekday <- weekdays(master.df$flight.deptime, abbreviate = TRUE)

#one last piece - the API returned the wrong format of airport code (EPMO instaed of WMI for Modlin in Warsaw). We shall fix this
master.df <- master.df %>% mutate(flight.dest = replace(flight.dest, which(flight.dest == 'EPMO'), 'WMI')) %>% mutate(flight.origin = replace(flight.origin, which(flight.origin == 'EPMO'), 'WMI'))

#now merge this data frame with the data frame of airports, their official names and coordinates
airport.reference <- read.csv('airports.csv', header = F) #loading the data
colnames(airport.reference) <- c('airport.id', 'name', 'city', 'country', 'iata', 'icao', 'lat', 'long', 'alt', 'tmz', 'dst', 'tzd')
airport.reference <- airport.reference %>% select(2:5, 7:8)

#add missing Tuzla Airport
tuzla <- data.frame(name = 'Tuzla', city = 'Tuzla', country = 'Bosnia & Herzegovina', iata = 'TZL', lat = 44.4586, long = 18.7247)
airport.reference <- bind_rows(airport.reference, tuzla)

master.df <- left_join(master.df, airport.reference, by = c('flight.origin'='iata'))
master.df <- left_join(master.df, airport.reference, by = c('flight.dest'='iata'))

master.df <- master.df %>% select(-1) #get rid of the row index

colnames(master.df) <- c('flight.date', 'fl.num', 'origin', 'dest', 'dep.time', 'arr.time', 'equipment', 'weekday', 'dep.airport', 'dep.city', 'dep.country', 'dep.lat', 'dep.long', 'arr.airport', 'arr.city', 'arr.country', 'arr.lat', 'arr.long')

#this goes into the folder with our app
write.csv(master.df, 'master-df.csv', row.names = FALSE)
#-------#

#Some preliminary analysis

