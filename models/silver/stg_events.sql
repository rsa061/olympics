with source as (

    select distinct
        {{ dbt_utils.generate_surrogate_key(['disciplina', 'evento', 'tipo_participante']) }} as id_evento,
        upper(trim(disciplina)) as disciplina,
        upper(trim(evento)) as evento,
        upper(trim(tipo_participante)) as tipo_participante
    from {{ ref('bronze__olympic_results') }}
    where evento is not null

)

select
    id_evento,
    disciplina,
    evento,
    tipo_participante
from source