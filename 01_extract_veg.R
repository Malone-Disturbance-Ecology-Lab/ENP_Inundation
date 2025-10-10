## --------------------------------------------- ##
#         Extract Vegetation to Points
## --------------------------------------------- ##
# Script author(s): Angel Chen

# Purpose:
## This script converts the ENP BICY Landsat raster to points
## and combines the point data with vegetation info from the NPS DataStore.

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
#       Convert Landsat Raster to Points -----
## --------------------------------------------- ##

# Read in Landsat raster
landsat_raster <- terra::rast(file.path("appeears_landsat_data", "ENP_BICY_AOI", "L09.002_SR_B1_CU_doy2025216_aid0001.tif"))

landsat_points <- landsat_raster %>%
  # Convert Landsat raster to point data
  as.data.frame(na.rm = F, xy = T) %>%
  # Replace missing values with "9999" as placeholder
  # So we can extract veg info to the points later
  dplyr::mutate(L09.002_SR_B1_CU_doy2025216_aid0001 = dplyr::case_when(
    is.na(L09.002_SR_B1_CU_doy2025216_aid0001) ~ 9999,
    T ~ L09.002_SR_B1_CU_doy2025216_aid0001
  )) %>%
  # Convert point data to sf object with coordinates
  sf::st_as_sf(coords = c("x", "y"), crs = 4326)

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
  sf::st_transform(crs = sf::st_crs(landsat_points))

## --------------------------------------------- ##
#               Extraction -----
## --------------------------------------------- ##

# Extract vegetation info to points
veg_points_v0 <- sf::st_join(landsat_points, ENP_BICY, join = st_within)

# Filter out the points that don't have vegetation info
veg_points_v1 <- veg_points_v0 %>% 
  dplyr::select(-L09.002_SR_B1_CU_doy2025216_aid0001) %>%
  dplyr::filter(!is.na(Region))

# Check
# veg_points_v1 %>%
#   ggplot() +
#   geom_sf(aes(geometry = geometry, color = L2_name))

# Export extracted vegetation points
sf::st_write(veg_points_v1, file.path(server_folder, "ENP_BICY", "ENP_BICY_veg.shp"),
             append = FALSE)
