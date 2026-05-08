{{ config(
    materialized='incremental',
    incremental_strategy='append'
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

    {% if is_incremental() %}
    where cod_juego not in (
        select cod_juego
        from {{ this }}
    )
    {% endif %}

)

select *
from source