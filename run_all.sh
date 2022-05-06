#!/bin/bash 

# retrieve the necessary data:
echo "Retrieving FCC Form 477 data from FCC Open Data API..."
echo
curl "https://opendata.fcc.gov/api/views/hicn-aujz/rows.csv?accessType=DOWNLOAD&sorting=true" -o fcc.csv
bzip2 fcc.csv 
echo "Retrieving Ookla performance data from Amazon S3..."
echo
aws s3 cp --no-sign-request s3://ookla-open-data/shapefiles/performance/type=fixed/year=2022/quarter=1/2022-01-01_performance_fixed_tiles.zip .
echo "Retrieving census tract shapefiles from Tiger Census FTP..."
echo
curl ftp://ftp2.census.gov/geo/tiger/GENZ2021/shp/cb_2021_us_tract_500k.zip -o cb_2021_us_tract_500k.zip
echo "Making data directory and moving datasets to directory..."
echo
mkdir -p data
mv fcc.csv.bz2 2022-01-01_performance_fixed_tiles.zip cb_2021_us_tract_500k.zip data/

# self-explanatory
echo "Processing FCC data..."
echo
./fcc_redux.py
echo "Aggregating FCC data..."
echo
./fcc_agg.py
echo "Pulling and processing ACS data..."
echo
./get_acs.py
echo "Aggregating Ookla data..."
echo
./ookla_agg.py
echo "Merging datasets and creating a geoJSON file..."
echo
./merge.py
# --> creates broadband.geojson and broadband.csv.gz

