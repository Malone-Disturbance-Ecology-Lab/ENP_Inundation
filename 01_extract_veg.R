## --------------------------------------------- ##
#         Extract Vegetation to Points
## --------------------------------------------- ##
# Script author(s): Angel Chen

# Purpose:
## This script harmonizes the ENP and BICY shapefiles,
## rasterizes them to the Landsat raster,
## and finally converts them to point data.

## --------------------------------------------- ##
#               Housekeeping -----
## --------------------------------------------- ##

# Load necessary libraries
# If you don't have the "librarian" package, uncomment the next line and run it to install the package
# install.packages("librarian")
librarian::shelf(sf, terra, tidyverse)

# Point to folder on MaloneLab server
server_folder <- file.path("/", "Volumes", "malonelab", "Research", "ENP", "ENP_BICY_veg_geospatial_files") 

## --------------------------------------------- ##
#           Prepare Landsat Raster -----
## --------------------------------------------- ##

# Read in Landsat raster
landsat_raster <- terra::rast(file.path("appeears_landsat_data", "ENP_BICY_AOI", "L09.002_SR_B1_CU_doy2025216_aid0001.tif")) %>%
  # Fill out every cell with a value
  terra::setValues(1:ncell(.)) 

## --------------------------------------------- ##
#   Harmonize ENP and BICY Geospatial Data -----
## --------------------------------------------- ##

# Read in West BICY shapefile
wbicy_veg <- sf::st_read(file.path(server_folder, "BICY", "shapefile_data", "wbicy_veg", "wbicy_veg.shp")) %>%
  # Remove unnecessary columns
  dplyr::select(-c(OBJECTID, Imagery, SHAPE_Leng, SHAPE_Area)) %>%
  # Standardize columns
  dplyr::rename(VegCode_Level = Veg_Level,
                VegCode_Name = Veg_Name) %>%
  # Create new Region column
  dplyr::mutate(Region = "WBICY", .before = Cell_ID) %>%
  # Create empty L7_name
  dplyr::mutate(L7_name = NA_character_, .after = L6_name)

# Read in East BICY shapefile
ebicy_veg <- sf::st_read(file.path(server_folder, "BICY", "shapefile_data", "ebicy_veg", "ebicy_veg.shp")) %>%
  # Remove unnecessary columns
  dplyr::select(-c(OBJECTID, SHAPE_Leng, SHAPE_Area)) %>%
  # Standardize columns
  dplyr::rename(Cell_ID = Sort_Cell_,
                VegCode_Level = VegCode_L,
                VegCode_Name = VegCode_N) %>%
  # Create new Region column
  dplyr::mutate(Region = "EBICY", .before = Cell_ID)

# Read in ENP gdb file
enp_veg <- sf::st_read(dsn = file.path(server_folder, "ENP", "original_data", "EVER_VegMap_Geospatial_Product_&_Report_v20210518",
                                       "Geospatial_Vegetation_Information", "EVER_VegMap_v20200930.gdb"),
                         layer = "EVER_VegMap_Vegetation") %>%
  # Remove unnecessary columns
  dplyr::select(-c(Area_Hectares, Area_Acres, Shape_Length, Shape_Area)) %>%
  # Standardize columns
  dplyr::rename(VegCode_Name = NAME,
                L1_name = L1_Name,
                L2_name = L2_Name,
                L3_name = L3_Name,
                L4_name = L4_Name,
                L5_name = L5_Name,
                L6_name = L6_Name,
                L7_name = L7_Name,
                geometry = Shape) %>%
  # Create new Region column
  dplyr::mutate(Region = "ENP", .before = Cell_ID)

# Combine ENP and BICY sf dataframes
ENP_BICY <- rbind(enp_veg, wbicy_veg, ebicy_veg) %>%
  # Reproject to Landsat CRS (EPSG:4326)
  sf::st_transform(crs = sf::st_crs(landsat_raster))

## --------------------------------------------- ##
#       Convert Veg Shapefile to Points -----
## --------------------------------------------- ##

# Rasterize our veg shapefile to the Landsat raster
ENP_BICY_raster <- terra::rasterize(x = ENP_BICY, y = landsat_raster, field = "L3_name", background = NA) 

# Convert from raster to points
ENP_BICY_pts <- terra::as.points(ENP_BICY_raster) %>% 
  # Convert back to sf object
  sf::st_as_sf()

# Check
# ENP_BICY_pts %>%
#   ggplot() +
#   geom_sf(aes(geometry = geometry, color = L3_name)) + 
#   theme(legend.position = "none")

# Export vegetation points
sf::st_write(ENP_BICY_pts, file.path(server_folder, "ENP_BICY", "ENP_BICY_veg.shp"),
             append = FALSE)
