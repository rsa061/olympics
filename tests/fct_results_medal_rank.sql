select *
from {{ ref('fct_results') }}
where tipo_medalla in ('GOLD', 'SILVER', 'BRONZE')
      and posicion_ranking is not null
      and posicion_ranking > 4