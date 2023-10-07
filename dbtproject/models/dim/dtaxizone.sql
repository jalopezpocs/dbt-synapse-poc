{{
    config(
        pre_hook=[
            "update tgt
             set
	             tgt.Borough = src.Borough, 
	             tgt.[Zone] = src.[Zone], 
	             tgt.service_zone = src.service_zone
             from
	             {{this}} tgt
	             inner join {{ source('stg_src_to_dims', 'taxi_zone') }} src on src.LocationID = tgt.LocationID"
        ], 
        post_hook=[
            "insert into {{this}} (LocationID, Borough, [Zone], service_zone)
             select
                 src.LocationID, src.Borough, src.[Zone], src.service_zone
             from
                 {{ source('stg_src_to_dims', 'taxi_zone') }} src
             where
                 not exists (select 1 from {{this}} tgt where src.LocationID = tgt.LocationID)"
        ], 
        dist='REPLICATE'
    )
}}

SELECT
    LocationID,
    Borough,
    "Zone", 
    service_zone
FROM {{ source('stg_src_to_dims', 'taxi_zone') }}
WHERE 1 = 0
