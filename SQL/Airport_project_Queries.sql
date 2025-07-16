create database airport_db;
use airport_db;

SELECT * FROM airport2 limit 5;

-- trim the data
SELECT 
  DISTINCT LEFT(Fly_date, 4) AS Year
FROM airport2
ORDER BY Year;
CREATE TABLE airport_small AS
SELECT *
FROM airport2
WHERE Fly_date BETWEEN '2009-01-01' AND '2009-01-31';

SELECT 
  DISTINCT LEFT(Fly_date, 4) AS Year
FROM airport2
ORDER BY Year;
CREATE TABLE airport_short AS
SELECT *
FROM airport2
WHERE Fly_date BETWEEN '2008-01-01' AND '2009-01-31';

-- Problem Statement 1
-- The objective is to calculate the total number of passengers for each pair of origin and destination airports. 
select 
Origin_airport,
Destination_airport,
sum(Passengers) as totaL_passengers
from
 airport_small
group by 
Origin_airport,Destination_airport
order by total_passengers desc;

-- Problem Statement 2
-- Here the goal is to calculate the average seat utilization for each flight by dividing the number of passengers by the total number of seats available. 
select 
Origin_airport,Destination_airport,avg(cast(Passengers as FLOAT)/nullif(Seats,0))*100 as average_seats_utilization
from airport_small
group by Origin_airport,Destination_airport
order by average_seats_utilization desc;
  
 -- Problem Statement 3
 -- The aim is to determine the top 5 origin and destination airport pairs that have the highest total passenger volume. 
select 
Origin_airport,Destination_airport,sum(Passengers) as total_passenger 
from airport_small
group by Origin_airport,Destination_airport
order by total_passenger desc
limit 3;

-- Problem Statement 4
-- The objective is to calculate the total number of flights and passengers departing from each origin city. 
select 
Origin_city,
count(Flights) total_flights,
sum(Passengers) total_passengers
from airport_small
group by 
Origin_city
order by
total_passengers desc;

-- Problem Statement 5
-- The aim is to calculate the total distance flown by flights originating from each airport. 
select 
Origin_airport,
sum(Distance) total_distance
from airport_small
group by 
Origin_airport
order by
total_distance desc;

-- Problem Statement 6
-- The objective is to group flights by month and year using the Fly_date column to calculate the number of flights, total passengers, and average distance traveled per month.
select 
year(Fly_date) as Year ,
month(FLy_date) as Month,
count(Flights) as total_flight,
sum(Passengers) as total_passengers,
avg(Distance) as avg_distance
from
airport_small
group by 
Year,month
order by 
Year desc,Month desc;

-- Problem Statement 7
-- The goal is to calculate the passenger-to-seats ratio for each origin and destination route and filter the results to display only those routes where this ratio is less than 0.5.
select 
Origin_airport,
Destination_airport,
sum(Passengers) as total_passengers,
sum(Seats) as total_seats,
cast(sum(Passengers) as float)/Nullif(sum(Seats),0) as passengers_to_seat_ratio
from
airport_small
group by 
Origin_airport,
Destination_airport
having
passengers_to_seat_ratio<0.5
order by 
passengers_to_seat_ratio ;

-- Problem statement 8
-- The aim is to determine the top 3 origin airports with the highest frequency of flights.
select 
Origin_airport,
count(Flights) as total_flights
from 
airport_small
group by 
Origin_airport
order by 
total_flights desc
limit 3;

-- Problem Statement 9
--  The objective is to identify the city (excluding Bend, OR) that sends the most flights and passengers to Bend, OR.
select 
Origin_city,
count(Flights) as total_flights,
sum(Passengers) as total_passengers
from 
airport_small
where 
Destination_city="Bend, OR" and 
Origin_city<>"Bend, OR"
group by 
Origin_city
order by 
total_flights desc,
total_passengers desc
limit 3;


-- Problem Statement 10
-- The aim is to identify the longest flight route in terms of distance traveled, including both the origin and destination airports.

select 
Origin_airport,
Destination_airport,
max(Distance) as long_distance
from 
airport_small
group by 
Origin_airport,
Destination_airport
order by 
long_distance desc
limit 1;

-- Problem Statement 11
-- The objective is to determine the most and least busy months by flight count across multiple years

with Monthly_flights as 
(select 
Month(fly_date) as Month,
count(Flights) as total_flight
from 
airport_small
group by 
Month)
select 
  Month,
  total_flight,
  CASE 
     when total_flight=(select max(total_flight) from Monthly_flights) then "Most Busy"
	 when total_flight=(select min(total_flight) from Monthly_flights) then "Least Busy"
     else null
  end as status
from 
     Monthly_flights
where 
     total_flight=(select max(total_flight) from Monthly_flights) or
	 total_flight=(select min(total_flight) from Monthly_flights);

-- Problem Statement 12 
-- The aim is to calculate the year-over-year percentage growth in passengers for each airport pair.

with Passenger_summery as 
(select 
Origin_airport,
Destination_airport,
year(fly_date) as year,
sum(Passengers) as total_passenger
from 
airport_small
group by 
Origin_airport,
Destination_airport,
year),
passenger_growth as 
(select 
 Origin_airport ,
 Destination_airport,
 year,
 total_passenger,
 lag(total_passenger) over (partition by Origin_airport,Destination_airport order by year) as Previous_year_passenger
 from Passenger_summery)
 
 select 
 Origin_airport ,
 Destination_airport,
 year,
 total_passenger,
 case 
     when Previous_year_passenger is not null then 
     ((total_passenger-previous_year_passenger)*100.0/ nullif(Previous_year_passenger,0))
     end as Growth_percentage
 from 
 passenger_growth
 order by 
 Origin_airport,
 Destination_airport,
 year;
 
-- Porblem Statement 13
-- This analysis will help identify trends in passenger traffic over time

with Flight_summery as 
(select 
Origin_airport,
Destination_airport,
year(fly_date) as year,
count(Flights) as total_flights
from 
airport_small
group by 
Origin_airport,
Destination_airport,
year),

flight_growth as 
(select 
Origin_airport,
Destination_airport,
year,
total_flights,
lag(total_flights) over (partition by Origin_airport,Destination_airport order by year) as previous_year_flight
from 
Flight_summery),
growth_rate as
(select 
Origin_airport,
Destination_airport,
year,
total_flights,
case
when previous_year_flight is not null and previous_year_flight>0 then 
((total_flights-previous_year_flight)*100.0/previous_year_flight)
else null
end as growth_rate,
case
when previous_year_flight is not null and total_flights>previous_year_flight then 
1
else 0
end as growth_indicator
from 
flight_growth)

select 
Origin_airport,
Destination_airport,
min(growth_rate) as Minimun_growth_rate,
max(growth_rate) as maximum_growth_rate
from 
growth_rate
where 
growth_indicator=1
group by 
Origin_airport,
Destination_airport
having 
max(growth_indicator)=1
order by 
Origin_airport,
Destination_airport;

-- Problem statement 14
-- The aim is to determine the top 3 origin airports with passenger-to-seats number of flights for weighting.

 with utilization_ratio as 
(select 
Origin_airport,
sum(Passengers) as total_passengers,
sum(Seats) as total_seats,
count(Flights) as total_flights,
sum(Passengers)*1.0/sum(Seats) as passengers_to_seat_ratio
from 
airport_small
group by 
Origin_airport),
Weighted_utilization as 
(select 
Origin_airport,
total_passengers,
total_seats,
total_flights,
passengers_to_seat_ratio,
(passengers_to_seat_ratio*total_flights)/sum(total_flights)
over () as Weighted_utilization
from
utilization_ratio)

select
Origin_airport,
total_passengers,
total_seats,
total_flights,
Weighted_utilization
from 
Weighted_utilization
order by 
Weighted_utilization desc
limit 3;

-- Problem Statement 15
-- The objective is to identify the peak traffic month for each highest number of passengers, passenger count.

with monthly_passenger_count as
(select
Origin_city,
year(Fly_date) as year ,
month(Fly_Date) as month,
sum(Passengers) as total_passengers
from 
airport_small
group by 
Origin_city,
year,month),

maximum_passenger_per_city as 
(select 
Origin_city,
max(total_passengers) as peak_passenger
from 
monthly_passenger_count
group by 
Origin_city)

select 
mpc.Origin_city,
mpc.year,
mpc.month,
mpc.total_passengers

from 
monthly_passenger_count as mpc
join
maximum_passenger_per_city as mppc 
on  mpc.Origin_city=mppc.Origin_city and 
mpc.total_passengers=mppc.peak_passenger 
order by 
mpc.Origin_city,
mpc.year,
mpc.month;

-- Problem Statement 16
-- The aim is to identify the routes (origin-destination pairs) that have experienced the largest decline in passenger numbers year-over-year.

with yearly_passenger_count as 
(select 
origin_airport,
Destination_airport,
year(Fly_date) as year,
sum(Passengers) as total_passengers
from 
airport_short
group by 
origin_airport,
Destination_airport,
year),

yearly_decline as 
(select 
y1.Origin_airport,
y1.Destination_airport,
y1.year as year1,
y1.total_passengers Passengers_year1,
y2.year as year2,
y2.total_passengers Passengers_year2,
((y2.total_passengers-y1.total_passengers)/nullif(y1.total_passengers,0))*100 as percentage_change
from 
yearly_passenger_count y1
join 
yearly_passenger_count y2
on y1.Origin_airport=y2.Origin_airport and
y1.Destination_airport=y2.Destination_airport and 
y1.year=y2.year-1)

select
Origin_airport,
Destination_airport,
year1,
Passengers_year1,
year2,
Passengers_year2,
percentage_change

from 
yearly_decline
where 
percentage_change<0 -- only decline routes

order by 
percentage_change
limit 5;

-- Problem Statement 17
--  The objective is to list all origin and destination airports that had at least 10 flights but maintained an average seat utilization (passengers/seats) of less %. 

with flights_stat as (select 
Origin_airport,
Destination_airport,
count(Flights) total_flights,
sum(Passengers) total_passengers,
sum(Seats) total_seats,
(sum(Passengers)/nullif(sum(Seats),0)) avg_seats_utilization
from
airport_short
group by
Origin_airport,Destination_airport)

select 
Origin_airport,
Destination_airport,
total_flights,
total_passengers,
total_seats,
round((avg_seats_utilization*100),2) as avg_seats_utilization_percentage
from 
flights_stat
where 
total_flights>=10 and
round((avg_seats_utilization*100),2)<50
order by 
avg_seats_utilization_percentage;

-- Problem Statement 18
--  The aim is to calculate the average flight distance for each unique city-to-city pair (origin and destination) and identify the routes with the longest average distance.
 
with distance_stat as 
(select 
Origin_city,
Destination_city,
avg(distance) as avg_flight_distance
from 
airport_short
group by 
Origin_city,
Destination_city)

select 
Origin_city,
Destination_city,
round(avg_flight_distance) avg_flight_distance
from
distance_stat
order by 
avg_flight_distance desc;

-- Problem Statement 19
-- The objective is to calculate the total number of flights and passengers for each year, along with the percentage growth in both flights and passengers compared to the previous year.

with yearly_summery as 
(select
year(Fly_date) year,
count(Flights) total_flight,
sum(Passengers) as total_passengers
from 
airport_short
group by year),
 
yearly_growth as (select 
year,
total_flight,
total_passengers,
lag(total_flight) over (order by year) as prev_flight,
lag(total_passengers) over (order by year) as prev_passenger
from 
yearly_summery)

select 
total_flight,
total_passengers,
round(((total_flight-prev_flight)/nullif(prev_flight,0)*100),2) flight_growth_percentage,
round(((total_passengers-prev_passenger)/nullif(prev_passenger,0)*100),2) passenger_growth_percentage
from 
yearly_growth;

-- Problem Statement 20
-- The aim is to identify the top 3 busiest routes (origin destination pairs) based on the total distance flown, weighted by the number of flights. 

with route_distance as 
(select 
Origin_airport,
Destination_airport,
sum(Flights) total_flight,
sum(Distance) total_Distance
from 
airport_short
group by 
Origin_airport,
Destination_airport),

weighted_route as 
(select 
Origin_airport,
Destination_airport,
total_flight,
total_distance,
total_distance*total_flight as weighted_distance
from 
route_distance)

select 
Origin_airport,
Destination_airport,
total_flight,
total_distance,
weighted_distance
from
weighted_route
order by 
weighted_distance desc
limit 5;





