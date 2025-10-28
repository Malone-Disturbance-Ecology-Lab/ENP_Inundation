# ENP_Inundation
A repo for the ENP Inundation project (work in progress)

## Script Explanations

- **00_get_landsat.R**: This script downloads data from Landsat 9 using the NASA AppEEARS API into your local machine.

- **00_get_ENP_BICY_veg.R**: This script downloads Everglades National Park (ENP) and Big Cypress (BICY) vegetation data from the NPS DataStore into the MaloneLab server. The Eastern BICY vegetation data is saved as `EBICYNP_VegMap_v20191031.zip`, the western BICY vegetation data is saved as `wbicynp_vegmap_and_rpt_v20200825`, and the ENP vegetation data is saved as `EVER_VegMap_Geospatial_Product_&_Report_v20210518.zip`. NOTE: the BICY data comes in .mdb format and will need to be converted to .shp for use (see below).

- **01_convert_veg_to_points.R**: This script harmonizes the ENP and BICY vegetation shapefiles, rasterizes them to the Landsat raster, and finally converts them to point data. Exports point shapefile under `malonelab` -> `Research` -> `ENP` -> `ENP_BICY_veg_geospatial_files` -> `ENP_BICY` -> `ENP_BICY_veg.shp`.

- **02_veg_fire_history.R**: This script extracts fire history raster data to vegetation sample points to generate a vegetation and fire history point shapefile. Exports point shapefile under `malonelab` -> `Research` -> `ENP` -> `ENP Fire` -> `FireHistory` -> `ENP_BICY_veg_fire_years.shp`.

## How to convert personal geodatabase (.mdb) to shapefile (.shp)

The geospatial information for Eastern and Western BICY is stored in `EBICYNP_VegMap.mdb` and `WBICYNP_VegMap_v20200825.mdb` inside their respective zip files. These files are personal geodatabases, which are a type of ESRI proprietary data format. 

How to convert .mdb to .shp according to this [YouTube tutorial](https://www.youtube.com/watch?v=RTtn0TA1fYM):

1. Using a Windows machine, download [Microsoft Access Database Engine 2016 Redistributable](https://www.microsoft.com/en-us/download/details.aspx?id=54920&irgwc=1)

2. Run the .exe to do the installation

3. Open ODBC Data Sources -> "Add ..." -> "Microsoft Access Driver (\*.mdb, \*.accdb)" -> "Finish" -> Enter a name for "Data Source Name" -> Select the .mdb file under "Database" -> "OK"

4. Once the database connection has been set, open QGIS -> "Layer" -> "Add Layer" -> "Add Vector Layer" -> "Database" -> "ESRI Personal Geodatabase" -> "New" -> Name: enter the same name you gave the data source, Host: enter the same name you gave the data source, Database: enter the same name you gave the data source -> "Test Connection" -> if it connects, click "Add" and skip the password prompt

5. After you select the layers to add, right-click on the layer and "Export" to export as shapefile

The exported BICY shapefiles are in `malonelab` -> `Research` -> `ENP` -> `ENP_BICY_veg_geospatial_files` -> `BICY` -> `shapefile_data`.
