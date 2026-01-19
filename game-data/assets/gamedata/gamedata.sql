/* @bruin
name: gamedata.gamedata
type: bq.sql
materialization:
  type: table
  strategy: create+replace

depends:
  - gamedata_staging.gamedata
@bruin */

SELECT * FROM gamedata_staging.gamedata 
WHERE 
player_id is not null and
event_name is not null and
session_id is not null and
revenue is not null and
variant is not null;
