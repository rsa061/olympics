with 

source as (

    select * from {{ source('bronze', 'olympic_results_raw') }}

),

renamed as (

    select
        trim(discipline_title) as disciplina,
        trim(event_title) as evento,
        trim(slug_game) as cod_juego,
        trim(participant_type) as tipo_participante,
        trim(medal_type) as tipo_medalla,
        trim(athletes) as atletas,
        case
            when upper(trim(rank_equal)) in ('TRUE', '1') then true
            when upper(trim(rank_equal)) in ('FALSE', '0') then false
            else null
        end as ranking_equal,
        try_to_number(rank_position) as posicion_ranking,
        trim(country_name) as nombre_ciudad,
        trim(country_code) as cod_ciudad,
        trim(country_3_letter_code) as cod_3_letras_ciudad,
        nullif(trim(athlete_url), '') as url_atleta,
        nullif(trim(athlete_full_name), '') as nombre_atleta,
        nullif(trim(value_unit), '') as puntuacion_valor,
        nullif(trim(value_type), '') as puntuacion_tipo
    from source

)

select * from renamed