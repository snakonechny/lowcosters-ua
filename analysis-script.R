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
#Now the same exercise for EasyJet
master.u2 <- data.frame()

airports <- eastern.europe
dates <- (22:28)
hours <- c(0, 6, 12, 18)

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
          master.u2 <- bind_rows(master.u2, temp)
        }
      }
    }
  }
}