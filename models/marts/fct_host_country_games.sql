{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='id_host_country_game'
) }}

with base as (
    select
        fr.id_juego,
        fr.id_pais,
        dg.anio,
        dg.estacion,
        dg.nombre as nombre_juego,
        dg.ciudad as ciudad_sede,
        dc.nombre_ciudad as nombre_pais,
        dc.cod_3_letras_ciudad as cod_3_letras_pais,
        count(*) as total_results,
        sum(case when fr.tiene_medalla = 1 then 1 else 0 end) as total_medals,
        sum(case when fr.tipo_medalla = 'GOLD' then 1 else 0 end) as gold_medals,
        sum(case when fr.tipo_medalla = 'SILVER' then 1 else 0 end) as silver_medals,
        sum(case when fr.tipo_medalla = 'BRONZE' then 1 else 0 end) as bronze_medals,
        count(distinct fr.id_evento) as events_participated,
        count(distinct case when fr.tiene_medalla = 1 then fr.id_evento end) as events_medaled
    from {{ ref('fct_results') }} fr
    left join {{ ref('dim_games') }} dg
        on fr.id_juego = dg.cod_juego
    left join {{ ref('dim_country') }} dc
        on fr.id_pais = dc.cod_ciudad
    {% if is_incremental() %}
    where dg.anio >= (select coalesce(max(anio), 0) from {{ this }}) - 1
    {% endif %}
    group by 1,2,3,4,5,6,7,8
),

with_history as (
    select
        *,
        lag(total_medals) over (
            partition by id_pais
            order by anio
        ) as medals_prev_games,
        avg(total_medals) over (
            partition by id_pais
            order by anio
            rows between 3 preceding and 1 preceding
        ) as avg_last_3_games
    from base
)

select
    {{ dbt_utils.generate_surrogate_key(['id_pais', 'id_juego']) }} as id_host_country_game,
    id_juego,
    id_pais,
    anio,
    estacion,
    nombre_juego,
    ciudad_sede,
    nombre_pais,
    cod_3_letras_pais,
    total_results,
    total_medals,
    gold_medals,
    silver_medals,
    bronze_medals,
    events_participated,
    events_medaled,
    medals_prev_games,
    avg_last_3_games,
    case
        when ciudad_sede = nombre_pais then 1
        else 0
    end as is_host,
    _fivetran_deleted,
    _fivetran_synced
from with_history