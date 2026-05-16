{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='url'
) }}

with source as (
    select
        url,
        nombre,
        juegos_participa,
        primer_juego,
        anio_nac,
        medallas,
        bio
    from {{ ref('stg_bronze__olympic_athletes_raw') }}
),

final as (
    select *
    from source
)

select *
from final