# Case study: Data analysis for Cyclistic bike-sharing company  

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
  

    
==========================================================================
## Data analysis process Step 1. Ask
==========================================================================  

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
  

  
==========================================================================
## Data analysis process Step 2. Prepare
==========================================================================  

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
   

    
==========================================================================
## Data analysis process Step 3. Process
==========================================================================  

### Cleaning the data and preparing it for analysis. RStudio
Due to the large size of the data set (over 5,829,030 rows by 13 columns), spreadsheet applications would not be suitable for cleaning and manipulating the raw data.
For data cleaning purposes RStudio was chosen, specifically for its capability to bulk load numerous source files. The required R packages for these tasks are ‘tidyverse’ and ‘data.table’. Along the data cleaning process every new step was saved to a new data frame in order to easier trace back to the previous step.
Below please find the RMarkdown notebook documenting the entire cleaning process.

=RMarkdown-start=====================================================  

title: "Cyclistic_cleaning"  
author: "Denis Mezenko"  
date: "2023-06-30"  
output: html_document  

  
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

### Data cleaning

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

### Exporting data to .csv file in order to import to MS SQL Server
```{r}
  write.csv(cyclistic236, 'C:/edu/Google Data Analytics/Case_study1/s2023l12/s2023l12.csv', row.names = FALSE, quote = FALSE)
```

 =RMarkdown-end=================================================================  
 
 
The resulting cleaned dataset consisted of 4,294,321 rows by 18 columns and was exported to a .csv file.
  
  
  
==========================================================================  
## Data analysis process Step 4. Analyze
==========================================================================  

The .csv file from the previous stage was imported for further analysis into MS SQL Server Management Studio using Import and Export Tool. SQL was used for data analysis and Tableau for data visualization.  
The analyzed data covers information about 4,294,321 unique rides made in the 12-month period between 01.06.2022 and 31.05.2023. In terms of the number of rides 2,666,209 or 62% were made by members and 1,628,112 or 38% were made by casual riders. In terms of time spent riding the situation is the opposite with member riders spending 48% of the time, and casual riders spending 52%.  
Members' rides appear to be distributed more evenly across the year. Their monthly number of rides varies from 101K to 324k. The high season falls for April-October showing 200-300K rides per month (8-12% of the total annual number of rides falling on every month in this band). For the rest of the year the members’ rides remain within 100-170K range (4-7%).  
Casual riders usage peaks during June-September period at 208-288K rides per month (13-18%), reduces to hundreds thousand in April, May, and October, and dramatically plummets to as low as tens of thousands in the colder months of the year (2-10%).  
The time spent riding shows quite different trends compared to the number of rides. If for member riders the riding time closely follows the number of rides (average ride duration remains fairly constant throughout the year, 10-14 minutes), the casual riders showing much longer ride duration times - from 14 minutes in December and January to 24 minutes in June and July.  
The two groups of riders also show different patterns of using bicycles of different types. Members prefer classical bikes (67%) over electric ones (33%). Casual riders also seem to prefer classical bikes using them for half of their rides, but along with the electric bikes (33%) they have also been using docked bikes (17%).  
Members and casual riders also appear to have different patterns of bike use in terms of days of the week as well as time of the day.  
Casual riders appear to have been using the bike-sharing service more during day time (46%) throughout all days of the week. The second most active band for them is evenings (30), and only then the mornings (20%). This trend remains through all days of the week. Weekends see the highest numbers of bike trips by casual users (36% of rides on Saturdays and Sundays vs 64% during all five weekdays) with peak on Saturdays (20% of all rides during the entire week). Casuals’ night rides are also notably more frequent on weekends.  
Member riders, on the contrary, make the majority of their rides between Monday and Friday (77% of all rides) with trips almost evenly distributed between mornings, daytime and evenings (28%, 43%, and 26% respectively) with daytime still leading. Members continue riding on weekends, but with much less trips (12% Saturdays and 11% Sundays). There is also a slight increase in night rides on weekends for members too.  
There is a significant difference between member and casual riders in terms of stations they have been using. Below please see top 5 stations most used by members and casual riders plotted on the map of Chicago - the stations most used by members and those most used by casual riders are in fact grouped in quite different areas geographically, distinctly apart from each other - please see [here] (https://public.tableau.com/app/profile/denis5215/viz/iCyclistic1/descriptive).  
Stations most used by casual riders are located in somewhat more recreational areas of Chicago mostly adjacent to the sea front, while those most used by member riders are much further west towards the parts of the city which appear to be more business and residential. In addition to that, all other stations used by member riders appear to be broadly dispersed across the entire city, while the stations used by the casual riders are mostly near the sea front.  
The data shows that the two groups of riders have differing patterns of use of the service run by Cyclistic. The main differences are in how the rides are distributed both geographically and in time - between months, days of the week, and times of the day.  
These differences suggest that the two groups of riders must be using the bike-share service for different purposes.  

Please see the visualisations of the discussed differences in bike use patters between the two types of riders [here] (https://public.tableau.com/app/profile/denis5215/viz/iCyclistic2/dash).  
Below please find the script of all SQL queries used in the analysis. 

=SQLstart=================================================================
```
-- Creating table in MS SQL Server
The following table was created to house the imported comma-separated data in relevant formats:

DROP TABLE IF EXISTS cyclistic.dbo.[raw]
SELECT * FROM cyclistic.dbo.[raw]

CREATE TABLE cyclistic.dbo.[raw] (
    ride_id VARCHAR(250) PRIMARY KEY,
    rideable_type VARCHAR(250) NULL,
    started_at DATETIME NULL,
    ended_at DATETIME NULL,
    start_station_name VARCHAR(250) NULL,
    start_station_id VARCHAR(250) NULL,
    end_station_name VARCHAR(250) NULL,
    end_station_id VARCHAR(50) NULL,
    start_lat FLOAT NULL,
    start_lng FLOAT NULL,
    end_lat FLOAT NULL,
    end_lng FLOAT NULL,
    member_casual VARCHAR(250) NULL,
    ride_time_min FLOAT,
    ride_month INT,
    ride_weekday VARCHAR(250),
    ride_hour INT,
    ride_daytime VARCHAR(250)
    )

-- Importing csv data
INSERT INTO cyclistic.dbo.[raw] (
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual,
    ride_time_min,
    ride_month,
    ride_weekday,
    ride_hour,
    ride_daytime
    )
    SELECT
   	 ride_id,
   	 rideable_type,
   	 started_at,
   	 ended_at,
   	 start_station_name,
   	 start_station_id,
   	 end_station_name,
   	 end_station_id,
   	 start_lat,
   	 start_lng,
   	 end_lat,
   	 end_lng,
   	 member_casual,
   	 ride_time_min,
   	 ride_month,
   	 ride_weekday,
   	 ride_hour,
   	 ride_daytime
   	 FROM cyclistic.dbo.[s2023l12]

-- Data exploration
--- Calculating total number of rides and ride time by member type
SELECT
    member_casual,
    COUNT(ride_id) AS rides_no,
    SUM(ride_time_min) AS rides_time
FROM cyclistic.dbo.[raw]
GROUP BY member_casual
ORDER BY SUM(ride_time_min)

--- Calculating total number of rides and ride time by rider type and bike type
SELECT
    member_casual,
    rideable_type,
    COUNT(ride_id) AS rides_no,
    SUM(ride_time_min) AS rides_time
FROM cyclistic.dbo.[raw]
GROUP BY member_casual, rideable_type
ORDER BY member_casual DESC, rideable_type--, SUM(ride_time_min)

--- Determining most frequently used start stations by each rider type
SELECT
    member_casual,
    start_station_name,
    --start_lat,
    --start_lng,
    COUNT(ride_id) AS start_trip_no
FROM cyclistic.dbo.[raw]
GROUP BY member_casual, start_station_name
HAVING COUNT(ride_id) > 10000
ORDER BY member_casual, COUNT(ride_id) DESC

--- Determining most frequently used end stations by each rider type
SELECT
    member_casual,
    end_station_name,
    --start_lat,
    --start_lng,
    COUNT(ride_id) AS end_trip_no
FROM cyclistic.dbo.[raw]
GROUP BY member_casual, end_station_name
HAVING COUNT(ride_id) > 10000
ORDER BY member_casual, COUNT(ride_id) DESC

--- Plotting on map 5 most used stations by rider type
---- Creating tables for top 5 used stations for casual riders
SELECT TOP 5
    member_casual,
    start_station_name,
    --start_lat,
    --start_lng,
    COUNT(ride_id) AS start_trip_no
INTO cyclistic.dbo.[stations_c_top5]
FROM cyclistic.dbo.[raw]
GROUP BY member_casual, start_station_name
HAVING member_casual = 'casual' AND COUNT(ride_id) > 10000
ORDER BY member_casual, COUNT(ride_id) DESC

SELECT TOP 5
    member_casual,
    start_station_name,
    --start_lat,
    --start_lng,
    COUNT(ride_id) AS start_trip_no
INTO cyclistic.dbo.[stations_m_top5]
FROM cyclistic.dbo.[raw]
GROUP BY member_casual, start_station_name
HAVING member_casual = 'member' AND COUNT(ride_id) > 10000
ORDER BY member_casual, COUNT(ride_id) DESC

--- Uniting tables
SELECT *
INTO cyclistic.dbo.[stations_cm_top5]
FROM cyclistic.dbo.[stations_c_top5]
UNION
SELECT * FROM cyclistic.dbo.[stations_m_top5]

SELECT
    member_casual,
    start_station_name,
    start_trip_no
FROM cyclistic.dbo.[stations_cm_top5]
ORDER BY member_casual DESC, start_trip_no DESC

SELECT * FROM cyclistic.dbo.[stations_cm_top5]

--- Creating table for station coordinates
SELECT
    start_station_name,
    AVG(start_lat) AS lat,
    AVG(start_lng) AS lng--,
    --s.member_casual,
    --s.start_trip_no    
INTO cyclistic.dbo.[stations_coordinates]
FROM cyclistic.dbo.[raw]
GROUP BY start_station_name

--- Stations coordinates for map plotting of stations most used by casual riders
SELECT
    s.*,
    r.lat,
    r.lng
FROM cyclistic.dbo.[stations_cm_top5] s
LEFT JOIN cyclistic.dbo.[stations_coordinates] r
ON s.start_station_name = r.start_station_name

-- How each rider type used bikes by month
SELECT
    ride_month,
    COUNT(CASE WHEN member_casual = 'member' THEN 1 END) rides_members,
    COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) rides_casuals
FROM cyclistic.dbo.[raw]
GROUP BY ride_month
ORDER BY ride_month

-- How each rider type used bikes by day of the week
SELECT
    ride_weekday,
    CASE
   	 WHEN ride_weekday = 'Monday' THEN 1
   	 WHEN ride_weekday = 'Tuesday' THEN 2
   	 WHEN ride_weekday = 'Wednesday' THEN 3
   	 WHEN ride_weekday = 'Thursday' THEN 4
   	 WHEN ride_weekday = 'Friday' THEN 5
   	 WHEN ride_weekday = 'Saturday' THEN 6
   	 WHEN ride_weekday = 'Sunday' THEN 7
    END wdn,
    COUNT(CASE WHEN member_casual = 'member' THEN 1 END) rides_members,
    COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) rides_casuals
FROM cyclistic.dbo.[raw]
GROUP BY ride_weekday
ORDER BY 2

-- How each rider type used bikes by day of the week and time of the day
SELECT
    ride_weekday,
    CASE
   	 WHEN ride_weekday = 'Monday' THEN 1
   	 WHEN ride_weekday = 'Tuesday' THEN 2
   	 WHEN ride_weekday = 'Wednesday' THEN 3
   	 WHEN ride_weekday = 'Thursday' THEN 4
   	 WHEN ride_weekday = 'Friday' THEN 5
   	 WHEN ride_weekday = 'Saturday' THEN 6
   	 WHEN ride_weekday = 'Sunday' THEN 7
    END wdn,
    ride_daytime,
    COUNT(CASE WHEN member_casual = 'member' THEN 1 END) rides_members,
    COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) rides_casuals
FROM cyclistic.dbo.[raw]
GROUP BY ride_weekday, ride_daytime
ORDER BY 2

-- Selecting data for Tableau dashboard
SELECT
    s.ride_id,
    s.rideable_type,
    s.start_station_name,
    c.lat,
    c.lng,
    s.member_casual,
    s.ride_time_min,
    s.ride_month,
    s.ride_weekday,
    s.ride_hour,
    s.ride_daytime
FROM cyclistic.dbo.[raw] s
LEFT JOIN cyclistic.dbo.[stations_coordinates] c
ON s.start_station_name = c.start_station_name
```

=SQLend=================================================================  
The final table was saved as .csv file to be used for building data visualizations using Tableau Public.  


==========================================================================
## Data analysis process Step 5. Share
==========================================================================  

The analysis results may be shared with the key stakeholders in a presentation using visualizations built with Tableau Public and stored at their website. 
[Descriptive data visualizations] (https://public.tableau.com/app/profile/denis5215/viz/iCyclistic1/descriptive)
[Interactive dashboard] (https://public.tableau.com/app/profile/denis5215/viz/iCyclistic2/dash )  
The visualizations help answer the main question addressed by Cyclistic’s marketing to data analysts: How do annual members and casual riders use Cyclistic bikes differently?  
  
### Key findings  
The results of the analysis answer the main question addressed to the analytics team - how do annual members and casual riders use Cyclistic bikes differently? The distinctly varying geography and patterns of using the bike-sharing service between the two groups of riders leads to assumption that casual and member riders tend to have different purposes for bikes.  
Member riders appear to predominantly use bicycles for daily commute which stems from distribution of their rides across days of the week, higher number of morning rides on weekdays, and more even distribution of bike use throughout the year with individual month riding frequencies most likely varying due to weather.  
Casual riders seem to be mostly cycling for leisure as evidenced by higher density of their rides falling on weekends and summer months, and the starting and ending stations being geographically concentrated around recreational areas.  
The understanding that the two categories of riders are using the bike-sharing service for two distinctly different purposes, commuting and leisure, empowers our team at Cyclistic to find out how to make switching from casual riding passes to annual memberships appealing for the casual riders, and come up with a viable marketing strategy which would make this conversion happen.  


==========================================================================
## Data analysis process Step 6. Act
==========================================================================  

### Conclusion and recommendations  
The data analysis revealed that member riders are using the bike-sharing service mostly for commuting, and casual riders - mostly for leisure. Since it has been determined by the finance team that the annual memberships are more profitable for Cyclistic than casual ride passes, the goal is to see how the value of annual memberships can be improved for casual leisure riders, so that they seriously consider converting to full membership.  

  
The following steps are advised:  
1. Conducting thorough research into how much additional profit Cyclistic may be positioned to generate with conversion of certain percentiles of its casual riders audience into full members. Get clear understanding of how much resources are available to Cyclistic to organize and successfully implement the complex of marketing measures designed to make the casual-to-member conversion. Plan ahead if any financial leverage is likely to become required on the way.
2. Introducing a brand new member riders package coming into force just before high season (April is the first month the casual rides start showing growth, so we could launch it in March) which would encourage casual riders to choose membership over the casual passes they are used to by having references to powerful values, and offering tangible perks and benefits. For example:
	- Use a powerful message saying that cycling more improves health and emotional wellbeing, and how it would be additionally so much cheaper for the casual riders, if  they want to get healthier and cycle more, to switch from more expensive limited passes to full memberships which would be much more financially reasonable over time;
	- Display public statistical information both on digital media and physically present at the stations (boards, stickers, leaflets) on how the growing use of cycling for all purposes, not only leisure (i.e. commuting, running errands) creates a powerful positive impact on the environment, reducing city congestion, improving city air quality;
	- Offer a discount on new membership passes (if signed up in April-June, the moths when casual bike trips see season rise);
	- Offer an extra discount for families, couples, any other groups of several riders switching from passes to memberships;
	- Offer additional encouragements to switch to full membership from casual passes, like special events with free entrance for members and an entrance fee for everyone else, special discounts and perks from interested partner businesses like producers of specialized accessories, clothes, health and wellness products, gyms and swimming pools (especially winter discounts for staying in shape and getting ready for the next biking season);
	- Bundle up Cyclistic membership with free or discounted tickets to movies, museums, especially those held when casual riders most use the bikes - summer months and weekends.
3. Advertising the new package scheme in all available digital and social media and create attractive visuals physically present at the bike stations, starting from the ones most used by casual riders, as well as on all the bicycles, well in advance before the new member package coming into force, perhaps even starting as early as Christmas and the New Year holidays - playing around new year resolutions theme, health, longevity, positive impact for environment.
  
Additional data about more specific interests of riders using the Cyclistic bike-share service would shed even more light on how marketing can better target casual riders and convince them to convert to full membership. Therefore a customer survey targeted at this task is also strongly advised.



  
  
