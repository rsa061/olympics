select 
    *
from {{ source('bronze', 'olympic_athletes_raw') }}
where games_participations != 0
    and first_game != null