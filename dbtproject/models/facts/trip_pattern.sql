{{config(index='CLUSTERED COLUMNSTORE INDEX',dist='HASH(LocationID)')}}

with base as 
(
 select
   year(convert([date], lpep_pickup_datetime)) * 10000 +  
   convert(int, 
	case 
	 when month(convert([date], lpep_pickup_datetime)) <= 9 then '0' + month(convert([date], lpep_pickup_datetime))
	 else month(convert([date], lpep_pickup_datetime))
	end) * 100 + 
   day(convert([date], lpep_pickup_datetime)) as PUDateKey, 
   tz.LocationID as LocationID, 
   td.passenger_count as passenger_count, 
   td.trip_distance as trip_distance
 from
  {{ source('stg_src_to_facts', "trip_data") }} td
   inner join {{ source('dim_src_to_facts', 'dtaxizone') }} tz on (td.PULocationID = tz.LocationID)
)
select
 a.PUDateKey as PUDateKey, a.LocationID as LocationID, sum(passenger_count) as passenger_count, sum(trip_distance) as trip_distance 
from
 base a
  inner join {{ source('dim_src_to_facts', 'dcalendar') }} ca on (a.PUDateKey = ca.date_key)
where passenger_count is not null
group by
 a.PUDateKey, a.LocationID