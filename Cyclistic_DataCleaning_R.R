### Setting environment (RStudio)
install.packages("tidyverse")
install.packages("data.table")
library(tidyverse)
library(data.table)

### Data source - csv files 2022.06-2023-05 from https://divvy-tripdata.s3.amazonaws.com/index.html

### Loading raw CSV data and consolidating into a df (RStudio)
raw <- list.files(path = 'C:/edu/Google Data Analytics/Case_study1/s2023l12', full.names = TRUE)
cyclistic23 <- rbindlist(lapply(raw,fread), fill = TRUE)

count(cyclistic23)

### Checking the imported data
colnames(cyclistic23)

### Checking for missing values
sum(is.na(cyclistic23))

###Determining columns with missing values
colSums(is.na(cyclistic23))

# ===== Cleaning ===== #

### Cleaning records with missing values
cyclistic231 <- na.omit(cyclistic23)

### Re-checking for missing values
sum(is.na(cyclistic231))

### Adding columns for ride lengths, month, weekday and time of day the rides were made
cyclistic232 <- cyclistic231 %>% 
  mutate(
    ride_time_min = difftime(ended_at, started_at, units='mins'),
    ride_month = month(started_at),
    ride_weekday = weekdays(started_at),
    ride_hour = hour(started_at),
    ride_daytime = case_when(
      ride_hour >= 6 & ride_hour < 12 ~'Morning',
      ride_hour >= 12 & ride_hour < 18 ~'Day',
      ride_hour >= 18 & ride_hour < 24 ~'Evening',
      ride_hour >= 0 & ride_hour < 6 ~'Night')
)

# Checking if any columns have na
colSums(is.na(cyclistic232))

### Removing records with zero or negative ride time
cyclistic233 <- cyclistic232[cyclistic232$ride_time_min > 0, ]

### Removing records with start coordinates similar to end coordinates
cyclistic234 <- cyclistic233[cyclistic233$start_lat != end_lat & start_lng != end_lng, ]

cyclistic234 %>% count(start_station_id == "")
cyclistic234 %>% count(start_station_name == "")
cyclistic234 %>% count(end_station_id == "")
cyclistic234 %>% count(end_station_name == "")

### Removing records with empty start and/or end station information
cyclistic235 <- cyclistic234[cyclistic234$start_station_id == 0 | end_station_id == 0, ] # returned empty table
cyclistic235 <- cyclistic234[cyclistic234$start_station_id != "", ]
cyclistic236 <- cyclistic235[cyclistic235$end_station_id != "", ]

### Checking for NULLs
cyclistic236 %>% count(start_station_name == "")
cyclistic236 %>% count(end_station_name == "")

View(cyclistic236) # Viewing the resulting data frame
colnames(cyclistic236) # Checking the columns
count(cyclistic236) # Counting records