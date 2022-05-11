# This script takes the U.S. county shapefile from the census,
# computes the centroids of each county,
# then exports a csv with the state fips, geoid and centroid coordinates
library(rgdal)
library(tidyverse)

# CENSUS COUNTY SHAPES
# downloaded from here
# https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html
counties <- readOGR(
  dsn="input/cb_2018_us_county_500k",
  verbose=FALSE
)

# centroid function from here 
# https://rpubs.com/Earlien/Computing_Centroids_of_Polygons
get.gc <- function(polygon){
  A <- polygon@area   # Area
  C <- polygon@coords # Coords of each vertix (long, lat)
  C1 <- C[-nrow(C),]  # x_i, y_i
  C2 <- C[-1,]        # x_{i+1}, y_{i+1}
  # Compute geometric centre
  GC <- c(
    sum((C1[,1] + C2[,1]) * (C1[,1]*C2[,2] - C2[,1]*C1[,2])) / (6*A),
    sum((C1[,2] + C2[,2]) * (C1[,1]*C2[,2] - C2[,1]*C1[,2])) / (6*A))
  # If the polygon is oriented clockwise, switch the signs
  if(polygon@ringDir == 1) GC <- -GC
  return(GC)
}

get.centroid.gc <- function(x, method = "average"){
  N <- length(x)  # Number of polygons
  # Initialise data.frame
  Centroids.cg <- data.frame(matrix(NA, N, 2, dimnames = list(NULL, c("long", "lat"))))
  
  for(i in 1:N){
    Polys <- x@polygons[[i]]
    n <- length(Polys@Polygons)
    if(n == 1){
      Centroids.cg[i,] <- get.gc(Polys@Polygons[[1]])
    }else{
      A <- sapply(Polys@Polygons, function(x) x@area) # Area of each polygon
      D <- sapply(Polys@Polygons, function(x) x@ringDir)  # Ring direction
      if(tolower(method) %in% c("l", "largest")){
        L <- which.max(A[which(D == 1)]) # Largest area of non-hole polygon
        Centroids.cg[i,] <- get.gc(Polys@Polygons[[L]])
      }else if(tolower(method) %in% c("a", "av", "average", "w", "weighted")){
        GC.part <- matrix(NA, n, 2)
        for(j in 1:n){
          Poly <- Polys@Polygons[[j]]
          GC.part[j,] <- get.gc(Poly)
        }
        # Weighted average distance between geometric centres
        A <- A * D
        A <- A / sum(A)
        Centroids.cg[i,] <- A %*% GC.part
      }
    }
  }
  return(Centroids.cg)
}

centroids <- get.centroid.gc(counties, method='largest') %>%
  cbind(counties@data[c('AFFGEOID')]) %>%
  cbind(counties@data[c('NAME')]) %>%
  cbind(counties@data[c('STATEFP')])

write_csv(centroids, 'mid/centroids.csv')


