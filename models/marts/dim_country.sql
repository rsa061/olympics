with source as (

    select distinct
        cod_ciudad,
        cod_3_letras_ciudad,
        nombre_ciudad
    from {{ ref('stg_bronze__olympic_results_raw') }}
    where cod_ciudad is not null

),

final as (

    select
        cod_ciudad,
        cod_3_letras_ciudad,
        nombre_ciudad
    from source

)

select *
from final