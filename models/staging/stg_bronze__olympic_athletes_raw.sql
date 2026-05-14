with 

source as (

    select * from {{ source('bronze', 'olympic_athletes_raw') }}

),

renamed as (

    select
        trim(athlete_url) as url,
        trim(athlete_full_name) as nombre,
        try_to_number(games_participations) as juegos_participa,
        trim(first_game) as primer_juego,
        try_to_number(athlete_year_birth) as anio_nac,
        nullif(trim(athlete_medals), '') as medallas,
        nullif(trim(bio), '') as bio

    from source

)

select * from renamed