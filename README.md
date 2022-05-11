# rscripts_roe
Analyzing demographic variables in counties far from the nearest clinic

This project is run in R Studio an consists of three scripts that should be run in the following order:

1. `01_geo.R` Finds the centroids of each county from a census county shapefile. Exports a csv with each county as a row and centroid info.
2. `02_matchClinics.R` Takes each county centroid and finds the distance to the nearest abortion clinic in three scenarios: current, Guttmacher's "certain" and Guttmacher's "likely" scenarios.
3. `03_joinCensus.R` Joins census data for each county into the dataset.

## About the data
`input/states.csv` is a dataset generated from [Guttmacher's analysis](https://www.guttmacher.org/abortion-rights-supreme-court) on which states are likely or certain to ban abortion if Roe is reversed. `1` means certain and `2` means likely.

`input/afd.csv` is a dataset of abortion clinic geographic locations from [ansirh.org](https://www.ansirh.org/).

The `input/acs2020_5yr ...` datasets are American Community Survey tabulations by county for each of our demographic variables, generated with the help of [censusreporter.org](censusreporter.org).

## Analysis

A full rundown of the analysis and some tabulations can be found in the file `./output/Analysis.md`, generated with the help of R Markdown.