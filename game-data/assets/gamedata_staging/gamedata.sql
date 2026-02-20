/* @bruin
name: gamedata_staging.gamedata
type: bq.sql
description: "Silver layer table that applies basic normalization and type casting on raw game event data. Includes trimming and lowercasing of identifiers, safe revenue casting, derived date/time fields, and load timestamp."
materialization:
    type: table
    strategy: time_interval
    time_granularity: date
    incremental_key: dt

depends:
  - gamedata_raw.gamedata
@bruin */

SELECT
    LOWER(TRIM(player_id)) AS player_id,
    event_time,
    date(event_time) as dt,
    LOWER(TRIM(event_name)) AS event_name,
    LOWER(TRIM(session_id)) AS session_id,
    level,
    SAFE_CAST(revenue AS FLOAT64) AS revenue,
    LOWER(TRIM(experiment_id)) AS experiment_id,
    LOWER(TRIM(variant)) AS variant,
    EXTRACT(HOUR FROM event_time) AS event_hour,
    EXTRACT(DAY FROM event_time) AS event_day,
    CURRENT_TIMESTAMP() AS loaded_at

FROM gamedata_raw.gamedata
WHERE date(event_time) BETWEEN '{{ start_date }}' AND '{{ end_date }}'

