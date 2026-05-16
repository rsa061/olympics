{{ config(
    materialized='table'
) }}

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
        nombre_ciudad,
        row_number() over (
            partition by cod_ciudad
            order by cod_3_letras_ciudad
        ) as rn
    from source
)

select
    cod_ciudad,
    cod_3_letras_ciudad,
    nombre_ciudad
from final
where rn = 1