# NOTE: this script depends on 'mid/distance.csv' which is created in matchClinics.R
library(tidyverse)

(countycsv <- read_csv('mid/distance.csv'))

join_shell <- countycsv %>%
  mutate(geoid = str_replace(AFFGEOID, '00000', '000'))

# OVERALL WOMEN POPULATION
# data from here:
# https://censusreporter.org/data/table/?table=B01001&geo_ids=01000US,050|01000US&primary_geo_id=01000US
(sex <- read_csv('input/acs2020_5yr_B01001_05000US28045/acs2020_5yr_B01001_05000US28045.csv'))
sex_shell <- sex %>%
  select(geoid, B01001026)

join_shell <- join_shell %>%
  left_join(sex_shell, by='geoid')

# POVERTY
# poverty data from here: 
# https://censusreporter.org/data/table/?table=B17001&geo_ids=01000US,050|01000US&primary_geo_id=01000US
(poverty <- read_csv('input/acs2020_5yr_B17001_05000US28045/acs2020_5yr_B17001_05000US28045.csv'))

# WOMEN IN POVERTY CALCULATION
# Women in poverty / (Women in poverty + Women not in poverty)
# B17001017 / (B17001017 + B17001046)

# select columns we need and rename join column
poverty_shell <- poverty %>%
  select(geoid, B17001017, B17001046)

# join census data to the counties weve selected
join_shell <- join_shell %>%
  left_join(poverty_shell, by='geoid') %>%
  mutate(pct_women_in_poverty = B17001017 / (B17001017 + B17001046))

# HEALTH INSURANCE
# insurance data from here: 
# https://censusreporter.org/data/table/?table=B27001&geo_ids=050|01000US&primary_geo_id=01000US
(insurance <- read_csv('input/acs2020_5yr_B27001_05000US28045/acs2020_5yr_B27001_05000US28045.csv'))

# WOMEN WITHOUT HEALTH INSURANCE
# Sum of women of each age group w/o insurance / Overall women B27001030
# (B27001033 + B27001036 + B27001039 + B27001042 + B27001045 + B27001048 +
# B27001051 + B27001054 + B27001057) / B27001030

insurance_shell <- insurance %>%
  mutate(women_wo_ins = B27001033 + B27001036 + B27001039 + B27001042 + B27001045 + B27001048 + B27001051 + B27001054 + B27001057) %>%
  select(geoid, women_wo_ins, B27001030)

join_shell <- join_shell %>%
  left_join(insurance_shell, by='geoid') %>%
  mutate(pct_women_wo_insurance = women_wo_ins / B27001030)

write_csv(join_shell, 'mid/distance_census.csv')

## DATA OUTPUT FOR DATAWRAPPER
dw <- join_shell %>%
  mutate(GEOID = str_replace(geoid,'05000US',''))

dw_with_roe <- dw %>%
  mutate('Miles to the nearest clinic' = miles_roe) %>%
  select(GEOID, 'Miles to the nearest clinic')

dw_certain_scenario <- dw %>%
  mutate('Miles to the nearest clinic' = miles_strict) %>%
  select(GEOID, 'Miles to the nearest clinic')

dw_likely_scenario <- dw %>%
  mutate('Miles to the nearest clinic' = miles) %>%
  select(GEOID, 'Miles to the nearest clinic')

write_csv(dw_with_roe, 'output/data-for-graphics/distance_to_nearest_clinic_current.csv')
write_csv(dw_certain_scenario, 'output/data-for-graphics/distance_to_nearest_clinic_certain_scenario.csv')
write_csv(dw_likely_scenario, 'output/data-for-graphics/distance_to_nearest_clinic_likely_scenario.csv')




