/* @bruin
name: gamedata.gamedata
type: bq.sql
materialization:
  type: table
  strategy: time_interval
  time_granularity: date
  incremental_key: dt

depends:
  - gamedata_staging.gamedata
@bruin */

SELECT * FROM gamedata_staging.gamedata 
WHERE 
player_id is not null and
event_name is not null and
session_id is not null and
revenue is not null and
variant is not null
AND dt BETWEEN '{{ start_date }}' AND '{{ end_date }}';
