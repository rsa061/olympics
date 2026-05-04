with 

source as (

    select * from {{ source('bronze', 'olympic_athletes_raw') }}

),

renamed as (
    select
        athlete_url as url_atleta,
        trim(athlete_full_name) as nombre_atleta,
        cast(athlete_year_birth as integer) as anio_nacimiento,
        cast(games_participations as integer) as total_juegos_participados,
        first_game as primer_juego,
        athlete_medals as medallas_raw,
        bio as biografia
    
    from source
)

select * from renamed