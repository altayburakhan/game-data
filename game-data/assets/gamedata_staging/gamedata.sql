/* @bruin
name: gamedata_staging.gamedata
type: bq.sql
materialization:
    type: table
    strategy: create+replace

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

