with source as (
    select *
    from {{ ref('stg_country') }}
)


select
    *
from source