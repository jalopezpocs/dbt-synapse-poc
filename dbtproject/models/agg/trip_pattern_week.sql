{{config(index='CLUSTERED COLUMNSTORE INDEX',dist='HASH(LocationID)')}}

with base_dates as (
select date_key, week_of_month, row_number() over (partition by [year], [month], week_of_month order by Date_key desc) rn from {{ source('dim_src_to_agg', 'dcalendar') }}
), 
only_weeks as 
(select date_key from base_dates where rn = 1)
select
 a.PUDateKey, a.LocationID, sum(a.passenger_count) passenger_count, sum(a.trip_distance) trip_distance
from
 {{ ref('trip_pattern') }} a
  inner join only_weeks b on (a.PUDateKey = b.date_key)
group by
 a.PUDateKey, a.LocationID