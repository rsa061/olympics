select
    disciplina,
    evento,
    tipo_participante,
    count(*) as n
from {{ ref('dim_event') }}
group by 1, 2, 3
having count(*) > 1