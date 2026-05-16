{{ config(
    materialized='incremental',
    unique_key='id_resultado',
    incremental_strategy='merge'
) }}

with source as (

    select *
    from {{ source('bronze', 'olympic_results_raw') }}

    {% if is_incremental() %}
    where concat(
        trim(slug_game), '|',
        trim(discipline_title), '|',
        trim(event_title), '|',
        trim(participant_type), '|',
        trim(country_code), '|',
        coalesce(nullif(trim(athlete_url), ''), ''), '|',
        coalesce(trim(rank_position), '')
    ) not in (
        select concat(
            cod_juego, '|',
            disciplina, '|',
            evento, '|',
            tipo_participante, '|',
            cod_ciudad, '|',
            coalesce(url_atleta, ''), '|',
            coalesce(to_varchar(posicion_ranking), '')
        )
        from {{ this }}
    )
    {% endif %}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key([
            "upper(trim(slug_game))",
            "upper(trim(discipline_title))",
            "upper(trim(event_title))",
            "upper(trim(participant_type))",
            "upper(trim(country_code))",
            "nullif(upper(trim(athlete_url)), '')",
            "try_to_number(rank_position)"
        ]) }} as id_resultado,
        upper(trim(discipline_title)) as disciplina,
        upper(trim(event_title)) as evento,
        upper(trim(slug_game)) as cod_juego,
        upper(trim(participant_type)) as tipo_participante,
        upper(trim(medal_type)) as tipo_medalla,
        upper(trim(athletes)) as atletas,
        case
            when upper(trim(rank_equal)) in ('TRUE', '1') then true
            when upper(trim(rank_equal)) in ('FALSE', '0') then false
            else null
        end as ranking_equal,
        try_to_number(rank_position) as posicion_ranking,
        upper(trim(country_name)) as nombre_ciudad,
        upper(trim(country_code)) as cod_ciudad,
        upper(trim(country_3_letter_code)) as cod_3_letras_ciudad,
        nullif(trim(athlete_url), '') as url_atleta,
        upper(trim(athlete_full_name)) as nombre_atleta,
        nullif(trim(value_unit), '') as puntuacion_valor,
        upper(trim(value_type)) as puntuacion_tipo
    from source

)

select * from renamed