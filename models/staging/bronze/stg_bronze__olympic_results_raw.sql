with 

source as (

    select * from {{ source('bronze', 'olympic_results_raw') }}

),

renamed as (

    select
        slug_game as id_juego,
        athlete_url as url_atleta,
        discipline_title as disciplina,
        event_title as evento,
        case 
            when lower(medal_type) = 'gold' then 'oro'
            when lower(medal_type) = 'silver' then 'plata'
            when lower(medal_type) = 'bronce' then 'bronce'
            else null 
        end as tipo_medalla,
        rank_position as posicion,
        cast(rank_equal as boolean) as es_empate,
        nullif(value_unit, '') as valor_resultado, 
        value_type as tipo_valor,
        participant_type as tipo_participante,
        athletes as lista_atletas,
        athlete_full_name as nombre_atleta,
        country_name as nombre_pais,
        country_code as codigo_pais,
        country_3_letter_code as codigo_pais_ioc
    from source

)

select * from renamed