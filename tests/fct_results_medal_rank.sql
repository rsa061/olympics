select *
from {{ ref('fct_results') }}
where medal_type in ('GOLD', 'SILVER', 'BRONZE')
  and rank_position not in (1, 2, 3)