select *
from {{ ref('fct_results') }}
where tipo_medalla in ('GOLD', 'SILVER', 'BRONZE')
  and posicion_ranking not in (1, 2, 3)