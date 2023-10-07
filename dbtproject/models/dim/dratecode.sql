{{
    config(
        pre_hook=[
            "update tgt
             set
	             tgt.rate_code = src.rate_code
             from
	             {{this}} tgt
	                 inner join {{ source('stg_src_to_dims', 'rate_code') }} src on src.rate_code_id = tgt.rate_code_id"
        ], 
        post_hook=[
            "insert into {{this}} (rate_code_id, rate_code)
             select
                 src.rate_code_id, src.rate_code
             from
                 {{ source('stg_src_to_dims', 'rate_code') }} src
             where
                 not exists (select 1 from {{this}} tgt where src.rate_code_id = tgt.rate_code_id)"
        ], 
        dist='REPLICATE'
    )
}}

SELECT
    rate_code_id,
    rate_code
FROM {{ source('stg_src_to_dims', 'rate_code') }}
WHERE 1 = 0
