{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='cod_juego'
) }}

with source as (
    select
        cod_juego,
        nombre,
        ciudad,
        estacion,
        anio,
        fecha_start,
        fecha_end
    from {{ ref('stg_bronze__olympic_hosts_raw') }}
),

final as (
    select *
    from source
)

select *
from final