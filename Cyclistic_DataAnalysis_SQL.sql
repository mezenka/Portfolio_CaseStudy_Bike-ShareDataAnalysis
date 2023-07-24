-- Checking the imported .csv
SELECT TOP 1000 * FROM cyclistic.dbo.[s2023l12]

-- Creating table in MS SQL Server
DROP TABLE IF EXISTS cyclistic.dbo.[raw]

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


-- Importing data
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
	COUNT(ride_id) AS start_trip_no
FROM cyclistic.dbo.[raw]
GROUP BY member_casual, start_station_name
HAVING COUNT(ride_id) > 10000
ORDER BY member_casual, COUNT(ride_id) DESC

--- Determining most frequently used end stations by each rider type
SELECT 
	member_casual,
	end_station_name,
	COUNT(ride_id) AS end_trip_no
FROM cyclistic.dbo.[raw]
GROUP BY member_casual, end_station_name
HAVING COUNT(ride_id) > 10000
ORDER BY member_casual, COUNT(ride_id) DESC

-- Plotting on map 5 most used stations by rider type
--- Creating tables for top 5 used stations for casual riders
SELECT TOP 5
	member_casual,
	start_station_name,
	COUNT(ride_id) AS start_trip_no
INTO cyclistic.dbo.[stations_c_top5]
FROM cyclistic.dbo.[raw]
GROUP BY member_casual, start_station_name
HAVING member_casual = 'casual' AND COUNT(ride_id) > 10000
ORDER BY member_casual, COUNT(ride_id) DESC

SELECT TOP 5
	member_casual,
	start_station_name,
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

-- Creating table for station coordinates
SELECT 
	start_station_name,
	AVG(start_lat) AS lat,
	AVG(start_lng) AS lng
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

-- How each rider type used bikes by month (number of rides)
SELECT 
	ride_month,
	COUNT(CASE WHEN member_casual = 'member' THEN 1 END) rides_members,
	COUNT(CASE WHEN member_casual = 'casual' THEN 1 END) rides_casuals
FROM cyclistic.dbo.[raw]
GROUP BY ride_month
ORDER BY ride_month

-- How each rider type used bikes by month (riding time)
SELECT 
	ride_month,
	CASE WHEN member_casual = 'member' THEN SUM(ride_time_min) END rides_members,
	CASE WHEN member_casual = 'casual' THEN SUM(ride_time_min) END rides_casuals
FROM cyclistic.dbo.[raw]
GROUP BY ride_month, member_casual
ORDER BY ride_month

-- How each rider type used bikes by month (average ride time)
SELECT 
	ride_month,
	CASE WHEN member_casual = 'member' THEN SUM(ride_time_min)/COUNT(ride_id) END rides_members,
	CASE WHEN member_casual = 'casual' THEN SUM(ride_time_min)/COUNT(ride_id) END rides_casuals
FROM cyclistic.dbo.[raw]
GROUP BY ride_month, member_casual
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

-- Preparing data for Tableau dashboard
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
