{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='id_resultado'
) }}

with source as (

    select
        upper(trim(slug_game)) as cod_juego,
        upper(trim(discipline_title)) as disciplina,
        upper(trim(event_title)) as evento,
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
        nullif(upper(trim(athlete_url)), '') as url_atleta,
        upper(trim(athlete_full_name)) as nombre_atleta,
        nullif(trim(value_unit), '') as puntuacion_valor,
        upper(trim(value_type)) as puntuacion_tipo
    from {{ source('bronze', 'olympic_results_raw') }}

    {% if is_incremental() %}
    where slug_game is not null
    {% endif %}

),

dedup as (

    select *
    from source
    qualify row_number() over (
        partition by
            cod_juego,
            disciplina,
            evento,
            tipo_participante,
            cod_ciudad,
            cod_3_letras_ciudad,
            coalesce(url_atleta, ''),
            coalesce(to_varchar(posicion_ranking), ''),
            coalesce(tipo_medalla, ''),
            coalesce(atletas, '')
        order by
            cod_juego,
            disciplina,
            evento,
            tipo_participante,
            cod_ciudad,
            cod_3_letras_ciudad,
            url_atleta
    ) = 1

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key([
            'cod_juego',
            'disciplina',
            'evento',
            'tipo_participante',
            'cod_ciudad',
            'cod_3_letras_ciudad',
            'url_atleta',
            'posicion_ranking',
            'tipo_medalla',
            'atletas'
        ]) }} as id_resultado,
        cod_juego,
        disciplina,
        evento,
        tipo_participante,
        tipo_medalla,
        atletas,
        ranking_equal,
        posicion_ranking,
        nombre_ciudad,
        cod_ciudad,
        cod_3_letras_ciudad,
        url_atleta,
        nombre_atleta,
        puntuacion_valor,
        puntuacion_tipo,
        case when tipo_medalla is not null then 1 else 0 end as tiene_medalla
    from dedup

)

select * from final