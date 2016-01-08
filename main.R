## Team Puma
## Jason Davis & Lieven Slenders. 
## source - Jeroen Roelofs & Louise Searle
## January 08 2016
# -------------------------------------------------------

## setting working directory
getwd()

# set working directory to you own specifications!!
setwd("D:/workspace/geoscripting/lesson5")

## Load source packages and functions.-------------------
# Load packages.
library(rgdal)
library(raster)
library(downloader)
# Load functions.
source('R/calcNDVI.R')
source('R/maskCloud.R')

## Load Landsat data ------------------------------------
# create folder to store data in
dir.create('data/')

# Download manually data from source.
#download('https://www.dropbox.com/s/i1ylsft80ox6a32/LC81970242014109-SC20141230042441.tar.gz?dl=0', "data/LC81970242014109-SC20141230042441.tar", quiet = T, mode = "wb")
#download('https://www.dropbox.com/s/akb9oyye3ee92h3/LT51980241990098-SC20150107121947.tar.gz?dl=0', "data/LT51980241990098-SC20150107121947.tar", quiet = T, mode = "wb")

# Unpack data.
untar("data/LC81970242014109-SC20141230042441.tar.gz", exdir = 'data/LC81970242014109-SC20141230042441/')
untar("data/LT51980241990098-SC20150107121947.tar.gz", exdir = 'data/LT51980241990098-SC20150107121947/')



# Assign relevant data to variables.
L8files <- list.files('data/LC81970242014109-SC20141230042441/', pattern = glob2rx('*.tif'), full.names = TRUE)
L5files <- list.files('data/LT51980241990098-SC20150107121947/', pattern = glob2rx('*.tif'), full.names = TRUE)

L8stack <- stack(L8files[c(1,5,6)])
L5stack <- stack(L5files[c(1,6,7)])

# # Check: Stack individual band plots.
# plot(L8stack[[1]])
# plot(L8stack[[2]])
# plot(L8stack[[3]])

# plot(L5stack[[1]])


## Pre-process Landsat data.----------------------
# Cloud layer extraction from stack.
L8cloud <- L8stack[[1]]
L5cloud <- L5stack[[1]]
#plot(L8cloud[[1]])

# Drop cloud layer from stack.
L8stack <- dropLayer(L8stack, 1)
L5stack <- dropLayer(L5stack, 1)


# Assign NA values to cloud-covered pixels in stack.
L8proc <- overlay(x = L8stack, y = L8cloud, fun = maskCloud)
L5proc <- overlay(x = L5stack, y = L5cloud, fun = maskCloud)
# Check: Cloud removed stack plots.
# plot(L8proc[[1]])
# plot(L5proc[[1]])

## Calculate change in NDVI.---------------------------------------------------

# NDVI calculation per year.
NDVI2014 <- overlay(L8proc[[1]], L8proc[[2]], fun=calcNDVI)
NDVI1990 <- overlay(L5proc[[1]], L5proc[[2]], fun=calcNDVI)

# # Check: NDVI plots.
# plot(NDVI2014)
# plot(NDVI1990)

# Temporal NDVI comparison.
# Warning suppressed.
# Warning message: Raster objects have different extents. Result for their intersection is returned.
# This is not a problem. This result is desireable as it allows the removal of earlier 
# extent functions, increasing efficiency.
NDVIchange <- suppressWarnings(NDVI1990 - NDVI2014)
# positive values mean that 1990 was greener than 2014. 
# negatives mean 2014 is greener due to extracting higher values.

## Check: NDVI change plot.
#plot(NDVIchange)

## Produce outputs.-------------------------------------------------------------
# Project raster.
NDVIchproj <- projectRaster(NDVIchange, crs='+proj=longlat')

## extra : projecting raster on googleEarth ---------------------------------------- 
# Set output working directory.
dir.create('output/')

# Create KML ouput file for visualising result in GoogleEarth.
KML(x=NDVIchproj, filename='output/NDVIchange.kml', overwrite = T)

# Create GRD output file for further analysis in Rstudio.
writeRaster(NDVIchproj, filename='output/NDVIchange.grd', datatype='INT2S', overwrite = T)