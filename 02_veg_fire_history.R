## --------------------------------------------- ##
#                 Fire History 
## --------------------------------------------- ##
# Script author(s): Angel Chen

# Purpose:
## This script extracts fire history raster data to vegetation sample points 
## to generate a vegetation and fire history point shapefile.

## --------------------------------------------- ##
#                Housekeeping -----
## --------------------------------------------- ##

# Load necessary libraries
# If you don't have the "librarian" package, uncomment the next line and run it to install the package
# install.packages("librarian")
librarian::shelf(sf, terra, tidyverse)

# Point to folders on MaloneLab server
firehist_folder <- file.path("/", "Volumes", "malonelab", "Research", "ENP", "ENP Fire", "FireHistory")
veg_folder <- file.path("/", "Volumes", "malonelab", "Research", "ENP", "ENP_BICY_veg_geospatial_files", "ENP_BICY") 

## --------------------------------------------- ##
#                 Extraction -----
## --------------------------------------------- ##

# Load sample pts
veg_sample_pts <- terra::vect(file.path(veg_folder, "ENP_BICY_veg.shp"))

# Read in tidy year of fire occurrence rasters
year_rasters <- terra::rast(file.path(firehist_folder, "EVER_BICY_1978_2023_year_occurrence.tif")) %>%
  # Reproject to CRS of sample points
  terra::project(terra::crs(veg_sample_pts), method = "near")

# Extract year of fire occurence data to vegetation sample points
fire_years <- terra::extract(year_rasters, veg_sample_pts, method = "simple", ID = TRUE)

# Add back in vegetation info
fire_years_veg <- cbind(as.data.frame(veg_sample_pts, geom = "WKT"), fire_years)

# Convert to sf object with CRS
fire_years_veg_sf <- fire_years_veg %>%
  sf::st_as_sf(wkt = "geometry", crs = sf::st_crs(veg_sample_pts))

# Check
# fire_years_veg_sf %>%
#   ggplot() +
#   geom_sf(aes(geometry = geometry, color = year_2023)) +
#   theme(legend.position = "none")

# Export vegetation points
sf::st_write(fire_years_veg_sf, file.path(firehist_folder, "ENP_BICY_veg_fire_years.shp"),
             append = FALSE)
