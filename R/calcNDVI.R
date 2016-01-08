## Jason & Lieven Team Puma
## January 08 2016
#--------------------------------------------------------
## CalcNDVI function.

# Calculates the NDVI per pixel in a raster file.
# NDVI = (NIR - R) / (NIR + R)
# Inputs: NIR band raster layer, R band raster layer.
# Output: NDVI raster, values between 0 and 1.

calcNDVI <- function(x, y) {
  ndvi <- (y - x) / (x + y)
  return(ndvi)
}