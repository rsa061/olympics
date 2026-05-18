{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='id_atleta'
) }}

with source as (
    select * from {{ ref('bronze__olympic_athletes') }}
),

final as (
    select 
        upper(trim(url)) as url,
        upper(trim(nombre)) as nombre,
        upper(trim(juegos_participa)) as juegos_participa,
        upper(trim(primer_juego)) as primer_juego,
        anio_nac,
        medallas,
        bio
    from source
)

select 
    {{ dbt_utils.generate_surrogate_key(['url', 'nombre']) }} as id_atleta,
    *
from final