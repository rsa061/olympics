with source as (

    select distinct
        disciplina
    from {{ ref('stg_bronze__olympic_results_raw') }}
    where disciplina is not null

)

select *
from source