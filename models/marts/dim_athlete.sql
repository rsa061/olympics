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
        bio,
        _fivetran_deleted,
        _fivetran_synced
    from {{ ref('stg_bronze__olympic_athletes_raw') }}

    {% if is_incremental() %}
    where url not in (
        select url
        from {{ this }}
    )
    or url in (
        select url
        from {{ this }}
        where nombre is null
           or juegos_participa is null
           or primer_juego is null
           or anio_nac is null
           or medallas is null
           or bio is null
    )
    {% endif %}

)

select *
from source