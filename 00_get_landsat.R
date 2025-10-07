## --------------------------------------------- ##
#             Download Landsat Data
## --------------------------------------------- ##
# Script author(s): Angel Chen

# Purpose:
## This script downloads data from Landsat 9 using the NASA AppEEARS API into your local machine. 
## The Landsat rasters will cover the Everglades National Park (ENP) and Big Cypress (BICY) National Preserve. 

## --------------------------------------------- ##
#               Housekeeping -----
## --------------------------------------------- ##

# Load necessary libraries
# If you don't have the "librarian" package, uncomment the next line and run it to install the package
# install.packages("librarian")
librarian::shelf(sf, appeears, terra)

# Create folder to store Landsat data
dir.create(path = file.path("appeears_landsat_data"), showWarnings = F)

# Specify your NASA Earth Data username 
my_user <- "anchen14"

# Enter your NASA Earth Data credentials 

# NOTE:
# There are 2 ways to enter your Earth Data credentials

# Method 1
# Run the following in the console with your own Earth Data username and password:
# rs_set_key(
#   user = "earth_data_user",
#   password = "XXXXXXXXXXXXXXXXXXXXXX"
# )

# Method 2 (if Method 1 fails)
# If this is your first time setting up your credentials, run:
# options(keyring_backend = "file")
# Then on the console, run the following with your own Earth Data username and password:
# rs_set_key(
#   user = "earth_data_user",
#   password = "XXXXXXXXXXXXXXXXXXXXXX"
# )
# And then set an additional local keyring password you can remember when prompted

# If you follow all the steps correctly, you can unlock your credentials 
# at the start of every session with just this line:
options(keyring_backend = "file")

# For more help, see https://github.com/bluegreen-labs/appeears?tab=readme-ov-file#setup

## --------------------------------------------- ##
#       Create ENP and BICY bounding box -----
## --------------------------------------------- ##

# Point to the folder with the ENP and BICY shapefiles
shapefile_folder <- file.path("/", "Volumes", "malonelab", "Research", "ENP", "shapefiles") 

# Read them in
enp <- sf::read_sf(file.path(shapefile_folder, "ENP.shp") )
bnp <- sf::read_sf(file.path(shapefile_folder, "Big_Cypress.shp") )

# Fix variable names
names(enp) <- names(bnp)

# Bind into one object
aoi <- rbind(enp, bnp)

# Union them together
enp_bnp <- sf::st_union(aoi)

# Create a bounding box with the outermost coordinates
bounding_box <- sf::st_as_sfc(sf::st_bbox(enp_bnp))

# Convert to a sf object
bounding_box_sf <- sf::st_as_sf(bounding_box)

# Check
# plot(bounding_box_sf)

## --------------------------------------------- ##
#           Create AppEEARS task -----
## --------------------------------------------- ##

# Create a dataframe for your AppEEARS task
df <- data.frame(
  task = "ENP_BICY_AOI", # name of task
  subtask = "subtask", # name of subtask 
  start = "2025-08-04", # start date for data
  end = "2025-08-11", # end date for data
  product = "L09.002", # data product ID
  layer = c("SR_B1") # name of specific band(s)
)

# Build the area-based task
task <- appeears::rs_build_task(
  df = df,
  roi = bounding_box_sf,
  format = "geotiff"
)

# Request the task to be executed
# If prompted, enter your local keyring password
appeears::rs_request(
  request = task,
  user = my_user,
  transfer = TRUE,
  path = "appeears_landsat_data",
  verbose = TRUE
)

# If RStudio gets disconnected, check your email for a link
# to download the requested AppEEARS files manually

# Check the Landsat image
# t <- terra::rast(file.path("appeears_landsat_data", "ENP_BICY_AOI", "L09.002_SR_B1_CU_doy2025216_aid0001.tif"))
# terra::plot(t)
