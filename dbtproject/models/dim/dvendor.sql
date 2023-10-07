{{
    config(
        pre_hook=[
            "update tgt
             set
	             tgt.vendor_name = src.vendor_name
             from
	             {{this}} tgt
	                 inner join {{ source('stg_src_to_dims', 'vendor') }} src on src.vendor_id = tgt.vendor_id"
        ], 
        post_hook=[
            "insert into {{this}} (vendor_id, vendor_name)
             select
                 src.vendor_id, src.vendor_name
             from
                 {{ source('stg_src_to_dims', 'vendor') }} src
             where
                 not exists (select 1 from {{this}} tgt where src.vendor_id = tgt.vendor_id)"
        ], 
        dist='REPLICATE'
    )
}}

SELECT
    vendor_id,
    vendor_name
FROM {{ source('stg_src_to_dims', 'vendor') }}
WHERE 1 = 0
