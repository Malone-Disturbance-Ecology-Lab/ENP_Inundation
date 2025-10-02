## --------------------------------------------- ##
#    Download raw ENP and BICY vegetation data
## --------------------------------------------- ##
# Script author(s): Angel Chen

# Purpose:
## This script downloads Everglades National Park (ENP) and Big Cypress (BICY) vegetation data 
## from the NPS DataStore into the MaloneLab server.

## Eastern BICY veg dataset landing page:
## https://irma.nps.gov/DataStore/Reference/Profile/2267445

## Western BICY veg dataset landing page:
## https://irma.nps.gov/DataStore/Reference/Profile/2278515

## ENP veg dataset landing page:
## https://irma.nps.gov/DataStore/Reference/Profile/2286556

## NOTE: the BICY data comes in .mdb format and will need to be converted to .shp for use (see README)

## --------------------------------------------- ##
#               Housekeeping -----
## --------------------------------------------- ##

# Load necessary libraries
library(curl)

# Point to folder on MaloneLab server
server_folder <- file.path("/", "Volumes", "malonelab", "Research", "ENP", "ENP_BICY_veg_geospatial_files") 

## --------------------------------------------- ##
#                  Download -----
## --------------------------------------------- ##

# Specify URL to download Eastern BICY vegetation data
ebicy_url <- "https://irma.nps.gov/DataStore/DownloadFile/640065"

# Download
curl::curl_download(url = ebicy_url, 
                    destfile = file.path(server_folder, "BICY_veg", "original_data", "EBICYNP_VegMap_v20191031.zip"),
                    quiet = F)

# Specify URL to download Western BICY vegetation data
wbicy_url <- "https://irma.nps.gov/DataStore/DownloadFile/646891"

# Download
curl::curl_download(url = wbicy_url, 
                    destfile = file.path(server_folder, "BICY_veg", "original_data", "wbicynp_vegmap_and_rpt_v20200825.zip"),
                    quiet = F)

# Specify URL to download ENP vegetation data
enp_url <- "https://irma.nps.gov/DataStore/DownloadFile/660232"

# Download
curl::curl_download(url = enp_url, 
                    destfile = file.path(server_folder, "ENP_veg", "original_data", "EVER_VegMap_Geospatial_Product_&_Report_v20210518.zip"),
                    quiet = F)
