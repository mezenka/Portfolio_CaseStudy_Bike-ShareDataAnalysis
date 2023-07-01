# Case study: Data analysis for Cyclistic bike-sharing companu  

Google Data Analytics Professional Certificate  
Capstone Project  
Denis Mezenko  
30.06.2023  


### Scenario
Cyclistic is a (fictional) bike-share company incorporated in 2016 with a geo-tracked fleet of 5,824 bicycles and 692 docking stations. It offers reclining bikes, hand tricycles, and cargo bikes, making bike-share more inclusive to people with disabilities and riders who can’t use a standard two-wheeled bike.   
Cyclistic’s marketing strategy has until now relied on building general awareness and appealing to broad consumer segments. Three pricing plans are offered: single-ride passes, full-day passes, and annual memberships. Customers with annual memberships are referred to as ‘members’, the rest of the customers - as ‘casual’ riders.  
Financial analysts at Cyclistic concluded that the annual memberships are more profitable than the casual passes. Cyclistic’s Director of marketing set a goal of designing a marketing strategy to convert existing casual riders into annual members. In order to do it, it is necessary to understand the differences between member and casual riders, see why casual riders may consider switching to the annual membership plan, and how to change the company’s marketing to make this conversion happen.  
Case study goal - producing a report with the following deliverables:  
1. Clear statement of the business task
2. Description of the data sources used
3. Documentation of data cleaning and manipulation processes
4. Analysis summary
5. Supporting visualizations
6. Recommendations based on the analysis
  
  
====================================================================================
## Data analysis process Step 1. Ask
====================================================================================
Statement of the **Business Task**
Analyze Cyclistic historic bike trip data in order to answer the following business questions:
1. How do annual members and casual riders use Cyclistic bikes differently?
2. Why may casual riders consider purchasing annual memberships?
3. How can Cyclistic use digital media to influence casual riders to become members?

The insights from the data analysis should help the company encourage their casual customers to buy annual membership plans.

Key stakeholders:
***Cyclistic’s customers*** - users of the bike-sharing programme who should benefit from the new marketing strategy that would make annual membership plans bring more value to them  
***Cyclistic’s marketing analysts*** - a team of data analysts responsible for collecting, analyzing, and reporting data that helps guide the marketing strategy  
***Cyclistic’s director of marketing*** - Ms Lily Moreno responsible for the development of campaigns and initiatives to promote the bike-share program  
***Cyclistic’s executives*** - notoriously detail-oriented executive team will decide whether to approve the recommended marketing program  
  

====================================================================================
## Data analysis process Step 2. Prepare
====================================================================================
For the purposes of this case study the historical trip data was used in the form of zipped .csv files for the latest 12 consecutive months (June 2022 - May 2023). The data was made publicly available under [Data License Agreement] (https://www.divvybikes.com/data-license-agreement) and  was downloaded from [here] (https://divvy-tripdata.s3.amazonaws.com/index.html).  
Because of privacy restrictions the data does not contain any personal information about the riders. The data includes anonymous ride IDs, bike types used, dates and times every ride was started and finished, names, IDs, and coordinates of bike stations, and the type of the rider using the bike.  
The source data is organized into separate .csv files, one for every month.  
As, according to the project scenario, the data has been received directly from the operating company, it can be assumed to be:  
- Reliable -  accurate, complete, unbiased, vetted, and proven fit for use
- Original - validated with the original source
- Comprehensive - contains all information necessary to answer the questions at hand
- Current - up-to-date and relevant to the task at hand
- Cited - used and referred to by credible sources
  
The original data files have been downloaded from the online location linked above, unzipped and organized into a separate designated subfolder on local computer in order to preserve the original data.  
The initial browsing of the source files identified several issues with the data:  
- some ride entries contained errors in the date-time field, showing negative difference between end and start times of individual trips
- some ride entries contained start station coordinates equal to end station coordinates, showing zero distance traveled during the ride
- some ride entries contained missing start and end stations’ names and IDs
- as the stations’ coordinates (latitudes and longitudes) appeared to had been generated by bike-mounted geo-location devices, they turned up to be not genuine for every station, having numerous coordinate for one station differing in the fifth digit and after.
   
All cleaning and transformation procedures performed with the source data are documented below and may be reproduced, reviewed and shared with peers and stakeholders if necessary.  
   
  
====================================================================================
## Data analysis process Step 3. Process
====================================================================================
Cleaning the data and preparing it for analysis. RStudio
Due to the large size of the data set (over 5,829,030 rows by 13 columns), spreadsheet applications would not be suitable for cleaning and manipulating the raw data.
For data cleaning purposes RStudio was chosen, specifically for its capability to bulk load numerous source files. The required R packages for these tasks are ‘tidyverse’ and ‘data.table’. Along the data cleaning process every new step was saved to a new data frame in order to easier trace back to the previous step.
Below please find the RMarkdown notebook documenting the entire cleaning process.

=RMarkdown-start===============================================================
---
title: "Cyclistic_cleaning"
author: "Denis Mezenko"
date: "2023-06-30"
output: html_document
---
### Setting up environment (RStudio)
```{r}
install.packages("tidyverse")
install.packages("data.table")
library(tidyverse)
library(data.table)
```
Data source - csv files 2022.06-2023-05 from https://divvy-tripdata.s3.amazonaws.com/index.html downloaded to local drive

### Loading source .csv files and consolidating them into a dataframe
```{r}
raw <- list.files(path = 'C:/edu/Google Data Analytics/Case_study1/s2023l12', full.names = TRUE)
cyclistic23 <- rbindlist(lapply(raw,fread), fill = TRUE)
```

### Checking the imported data
```{r}
# Counting number of entries (rows)
count(cyclistic23)
```

```{r{}}
# checking column names
colnames(cyclistic23)
```

```{r}
# checking for any missing values
sum(is.na(cyclistic23))
```

```{r}
# Determining columns with missing values
colSums(is.na(cyclistic23))
```

# ===== Data cleaning ===== #

```{r}
# Removing entries with missing values
cyclistic231 <- na.omit(cyclistic23)
```

```{r}
# Re-checking for missing values
sum(is.na(cyclistic231))
```

```{r}
# Generating columns for ride length, month, weekday and time of day the rides were made
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
```

```{r}
# Checking again if any columns have missing values now
colSums(is.na(cyclistic232))
```

```{r}
# Removing records with zero or negative ride time
cyclistic233 <- cyclistic232[cyclistic232$ride_time_min > 0, ]
```

```{r}
# Removing records with start coordinates similar to end coordinates
cyclistic234 <- cyclistic233[cyclistic233$start_lat != end_lat & start_lng != end_lng, ]
```

```{r}
# Removing records with empty start and/or end station information
cyclistic235 <- cyclistic234[cyclistic234$start_station_id != "", ]
cyclistic236 <- cyclistic235[cyclistic235$end_station_id != "", ]
```

```{r}
# Re-checking for missing values in these fields
cyclistic236 %>% count(start_station_name == "")
cyclistic236 %>% count(end_station_name == "")
```

```{r}
# Checking out the resulting data frame
count(cyclistic236) # Checking number of entries
View(cyclistic236) # Looking at the data set
```

### Exporting data to CSV file in order to import to MS SQL Server
```{r}
  write.csv(cyclistic236, 'C:/edu/Google Data Analytics/Case_study1/s2023l12/s2023l12.csv', row.names = FALSE, quote = FALSE)
```
 =RMarkdown-end=================================================================
The resulting cleaned dataset consisted of 4,294,321 rows by 18 columns and was exported to a .csv file.


  
  
