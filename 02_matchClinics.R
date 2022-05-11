# NOTE: this script depends on 'mid/centroids.csv' which is created in geo.R

library(tidyverse)
library(rgdal)
library(sp)
library(rgeos)
library(geosphere)

(clinics <- read_csv('input/afd.csv'))
(states <- read_csv('input/states.csv'))

(centroids <- read_csv('mid/centroids.csv'))

# restrictive states as vector
restrictive_states <- states$state

restrictive_states_strict <- states %>%
  filter(restrictive != 2)

restrictive_states_strict <- restrictive_states_strict$state

# we are going to exclude Puerto Rico and other territories
exclude <- c('78', '72', '69', '66', '60')

# new dataframe of clinics that are NOT in restrictive states
# remove clinics with no geographic information
`%notin%` <- Negate(`%in%`)
clinics_after_roe <- clinics %>%
  filter(state %notin% restrictive_states) %>%
  drop_na(latitude)

clinics_after_roe_strict <- clinics %>%
  filter(state %notin% restrictive_states_strict) %>%
  drop_na(latitude)

clinics <- clinics %>%
  drop_na(latitude)

#convert clinic data to spacial dataset
sp.clinics_after_roe <- clinics_after_roe
coordinates(sp.clinics_after_roe) <- ~longitude+latitude

sp.clinics_after_roe_strict <- clinics_after_roe_strict
coordinates(sp.clinics_after_roe_strict) <- ~longitude+latitude

sp.clinics <- clinics
coordinates(sp.clinics) <- ~longitude+latitude

# function finds nearest post-roe clinics to each county centroid
# https://stackoverflow.com/questions/21977720/r-finding-closest-neighboring-point-and-number-of-neighbors-within-a-given-rad

nearest_point <- function(row, sp2) {
  # first col is long
  long = as.numeric(row[1])
  
  # second is lat
  lat = as.numeric(row[2])
  
  coords = c(long, lat)
  
  # distance calculation
  d <- distm(coords, sp2)

  # index of closest point in comparison dataframe
  min.d <- apply(d, 1, function(x) order(x, decreasing=F)[1])
  #print(sp2[min.d,][1]['facid'])
  
  return(d[min.d])
}

`%notin%` <- Negate(`%in%`)

#filter out territories
centroids <- centroids %>%
  filter(STATEFP %notin% exclude)

distances <- apply(centroids, 1, function(x) nearest_point(x, sp.clinics_after_roe))
distances_strict_states <- apply(centroids, 1, function(x) nearest_point(x, sp.clinics_after_roe_strict))
distances_roe <- apply(centroids, 1, function(x) nearest_point(x, sp.clinics))
# function outputs miles from meters 
milesMeters <- function (meters) {
  miles <- 0.000621371 * meters
  return(miles)
}
# bind calculated distances to centroid dataset then
# convert distance to miles
with_distance <- centroids %>%
  cbind(distances) %>%
  cbind(distances_roe) %>%
  cbind(distances_strict_states) %>%
  mutate(miles = milesMeters(distances)) %>%
  mutate(miles_roe = milesMeters(distances_roe)) %>%
  mutate(miles_strict = milesMeters(distances_strict_states)) %>%
  select(long, lat, AFFGEOID, NAME, STATEFP, miles, miles_roe, miles_strict)

write_csv(with_distance, 'mid/distance.csv')
