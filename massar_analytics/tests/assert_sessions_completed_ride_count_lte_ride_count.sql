-- Fails when any shift has more completed rides than total rides.
select session_id
from {{ ref('int_sessions_enriched') }}
where completed_ride_count > ride_count
