{{ config(
    materialized='table'
) }}

with source as (
    select distinct
        upper(trim(cod_3_letras_ciudad)) as cod_3_letras_ciudad,
        upper(trim(cod_ciudad)) as cod_ciudad,
        upper(trim(nombre_ciudad)) as nombre_ciudad
    from {{ ref('stg_bronze__olympic_results_raw') }}
    where cod_3_letras_ciudad is not null
),

final as (
    select
        cod_3_letras_ciudad,
        cod_ciudad,
        nombre_ciudad,
        row_number() over (
            partition by cod_3_letras_ciudad
            order by cod_ciudad
        ) as rn
    from source
)

select
    cod_3_letras_ciudad,
    cod_ciudad,
    nombre_ciudad
from final
where rn = 1