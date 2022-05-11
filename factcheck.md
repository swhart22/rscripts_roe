# rscripts_roe
Analyzing demographic variables in counties far from the nearest clinic

## Fact-checking my work

1. `input/states.csv` has all of the states with planned restrictions to go into place after Roe v. Wade is overturned. I would love this doublechecked. I just pulled them from [our map](https://graphics.reuters.com/ABORTION-USA/OVERTURNED/gdpzyaangvw/index.html)

2. `mid/distance_census.csv` is the file that basically fuels the map. It would be great if we could double check these things for ten or more counties in different states: 

  a) the long/lat pair represent the center of the county (you can figure out which county is using the NAME and the STATEFP columns). Find [state fips codes here](https://www.nrcs.usda.gov/wps/portal/nrcs/detail/?cid=nrcs143_013696).
  
  b) double-check my poverty numbers. These are from the American Community Survey census data table B17001. You can, for example view the numbers for Ballard County, KY [here](https://censusreporter.org/data/table/?table=B17001&geo_ids=05000US21007&primary_geo_id=05000US21007#valueType|estimate). Get to a page like that for a given county by going [here](https://censusreporter.org/), searching the county name with table B17001. Heres what the columns map to
  
    i) B17001017: Women under the poverty line
    
    ii) B17001046: Women over the poverty line
    
    iii) My pct_women_in_poverty column is B17001017 / (B17001017 + B17001046)
    
  c) ditto for health insurance
  
    i) Get the total for women without health insurance by summing these columns (it's divvied up by age) B27001033 + B27001036 + B27001039 + B27001042 + B27001045 + B27001048 + B27001051 + B27001054 + B27001057
    
    ii) B27001030 should be the total number of women
    
    iii) pct_women_wo_insurance should be that sum from i / total from B27001030
    
