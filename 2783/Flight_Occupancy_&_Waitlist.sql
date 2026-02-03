/****************************************************************************************
PURPOSE
-------
Calculate how many passengers are **booked** and how many are **waitlisted**
for each flight based on flight capacity.

BUSINESS RULES
--------------
1. Each flight has a fixed seating capacity.
2. Passengers are assigned to flights.
3. If the number of passengers exceeds the flight capacity:
   - Passengers within capacity are considered "booked".
   - Remaining passengers are considered "waitlisted".
4. Passenger assignment order is determined by passenger_id.
5. Output booked and waitlisted passenger counts per flight.

HOW THE QUERY WORKS (STEP-BY-STEP)
----------------------------------
1. Join Flights and Passengers tables.
2. Assign a running count of passengers per flight using a window function.
3. Compare this running count with flight capacity.
4. Count passengers as booked or waitlisted using conditional aggregation.
****************************************************************************************/


/****************************************************************************************
TABLE: Flights
--------------
Stores flight-level information.

COLUMNS
-------
- flight_id : Unique identifier for each flight
- capacity  : Maximum number of passengers allowed on the flight
****************************************************************************************/

Create table Flights (
    flight_id int,
    capacity int
);

-- Remove existing data to keep script reusable
Truncate table Flights;


/****************************************************************************************
SAMPLE DATA: Flights
****************************************************************************************/

insert into Flights (flight_id, capacity) values ('1', '2');
insert into Flights (flight_id, capacity) values ('2', '2');
insert into Flights (flight_id, capacity) values ('3', '1');


/****************************************************************************************
TABLE: Passengers
-----------------
Stores passenger-to-flight mapping.

COLUMNS
-------
- passenger_id : Unique identifier for each passenger
- flight_id    : Flight the passenger is assigned to
****************************************************************************************/

Create table Passengers (
    passenger_id int,
    flight_id int
);

-- Remove existing data to keep script reusable
Truncate table Passengers;


/****************************************************************************************
SAMPLE DATA: Passengers
****************************************************************************************/

insert into Passengers (passenger_id, flight_id) values ('101', '1');
insert into Passengers (passenger_id, flight_id) values ('102', '1');
insert into Passengers (passenger_id, flight_id) values ('103', '1');

insert into Passengers (passenger_id, flight_id) values ('104', '2');
insert into Passengers (passenger_id, flight_id) values ('105', '2');

insert into Passengers (passenger_id, flight_id) values ('106', '3');
insert into Passengers (passenger_id, flight_id) values ('107', '3');


-- Verify input data
Select * from Flights;
Select * from Passengers;


/****************************************************************************************
QUERY LOGIC
****************************************************************************************/

with cte1 as (
    select
        f.*,
        p.passenger_id,
        count(p.passenger_id) over (
            partition by f.flight_id
            order by p.passenger_id
        ) as rnking
    from flights f
    left join passengers p
        on f.flight_id = p.flight_id
    where p.passenger_id is not null
)

select
    flight_id,
    sum(case when capacity >= rnking then 1 end) as booked_cnt,
    sum(case when capacity < rnking then 1 else 0 end) as waitlist_cnt
from cte1
group by flight_id;
