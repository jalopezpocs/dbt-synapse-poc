{{
    config(
        pre_hook=[
            "update tgt
             set
	             tgt.payment_type_desc = src.payment_type_desc
             from
	             {{this}} tgt
	                 inner join {{ source('stg_src_to_dims', 'payment_type') }} src on src.payment_type = tgt.payment_type"
        ], 
        post_hook=[
            "insert into {{this}} (payment_type, payment_type_desc)
             select
                 src.payment_type, src.payment_type_desc
             from
                 {{ source('stg_src_to_dims', 'payment_type') }} src
             where
                 not exists (select 1 from {{this}} tgt where src.payment_type = tgt.payment_type)"
        ], 
        dist='REPLICATE'
    )
}}

SELECT
    payment_type,
    payment_type_desc
FROM {{ source('stg_src_to_dims', 'payment_type') }}
WHERE 1 = 0
