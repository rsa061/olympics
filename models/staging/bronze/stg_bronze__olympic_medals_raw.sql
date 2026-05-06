with 

source as (

    select * from {{ source('bronze', 'olympic_medals_raw') }}

),

renamed as (

    select
        
        slug_game as id_juego,
        athlete_url as url_atleta,
        discipline_title as disciplina,
        event_title as evento,
        event_gender as genero,
        case 
            when lower(medal_type) = 'gold' then 'oro'
            when lower(medal_type) = 'silver' then 'plata'
            when lower(medal_type) = 'bronze' then 'bronce'
            else null 
        end as tipo_medalla,
        participant_type as tipo_participante,
        participant_tittle as titulo_participante,
        athlete_full_name as nombre_atleta,
        country_name as nombre_pais,
        country_code as codigo_pais,
        country_3_letter_code as codigo_pais_ioc

    from source

)
-- {{ dbt_utils.generate_surrogate_key(['field_a', 'field_b']) }} as surrogate_key
select * from renamed