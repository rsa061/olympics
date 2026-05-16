{{ config(
    materialized='incremental',
    unique_key='url',
    incremental_strategy='merge'
) }}

with source as (

    select *
    from {{ source('bronze', 'olympic_athletes_raw') }}

    {% if is_incremental() %}
    where athlete_url not in (
        select url
        from {{ this }}
    )
    {% endif %}

),

renamed as (

    select distinct
        upper(trim(athlete_url)) as url,
        upper(trim(athlete_full_name)) as nombre,
        try_to_number(games_participations) as juegos_participa,
        upper(trim(first_game)) as primer_juego,
        try_to_number(athlete_year_birth) as anio_nac,
        upper(nullif(trim(athlete_medals), '')) as medallas,
        upper(nullif(trim(bio), '')) as bio,
        row_number() over (
            partition by trim(athlete_url)
            order by trim(athlete_full_name)
        ) as rn
    from source

)

select
    url,
    nombre,
    juegos_participa,
    primer_juego,
    anio_nac,
    medallas,
    bio
from renamed
where rn = 1