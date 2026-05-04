with 

source as (

    select * from {{ source('bronze', 'olympic_hosts_raw') }}

),

renamed as (

     select
        game_slug as id_juego,
        cast(game_start_date as date) as fecha_inicio,
        cast(game_end_date as date) as fecha_fin,
        game_location as sede,
        game_name as nombre_juego,
        case 
            when lower(game_season) = 'summer' then 'verano'
            when lower(game_season) = 'winter' then 'invierno'
            else lower(game_season)
        end as temporada,
        cast(game_year as integer) as anio
    from source
)

select * from renamed