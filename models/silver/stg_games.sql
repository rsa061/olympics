{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='cod_juego'
) }}

with source as (
    select * from {{ ref('bronze__olympic_hosts') }}
),

final as (
    select 
        cod_juego,
        nombre,
        ciudad,
        estacion,
        anio,
        fecha_start,
        fecha_end
    from source
)

select *
from final