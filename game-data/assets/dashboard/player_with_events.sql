/* @bruin
name: dashboard.player_with_events
type: bq.sql
materialization:
  type: table
  strategy: create+replace

depends:
  - gamedata.gamedata
@bruin */

WITH events_with_stage AS (
  SELECT
    player_id,
    event_time,
    CASE
      WHEN event_name = 'install' THEN 0
      WHEN event_name = 'tutorial_complete' THEN 1
      WHEN event_name = 'level_complete' THEN 1 + level
    END AS stage
  FROM gamedata.gamedata
),
last_step as (
  SELECT
    player_id,
    stage AS level,
    event_time AS last_stage_time
  FROM events_with_stage
  QUALIFY ROW_NUMBER() 
  OVER (
      PARTITION BY player_id
      ORDER BY stage DESC, event_time ASC
    ) = 1
)
SELECT 
  player_id,
  level,
  last_stage_time,
  CASE level
    WHEN 0 THEN '0- install'
    WHEN 1 THEN '1- tutorial_complete'
    WHEN 2 THEN '2- level_1_completed'
    WHEN 3 THEN '3- level_2_completed'
    WHEN 4 THEN '4- level_3_completed'
    WHEN 5 THEN '5- level_4_completed'
    WHEN 6 THEN '6- level_5_completed'
    WHEN 7 THEN '7- level_6_completed'
    WHEN 8 THEN '8- level_7_completed'
    WHEN 9 THEN '9- level_8_completed'
    WHEN 10 THEN '10- level_9_completed'
    WHEN 11 THEN '11- level_10_completed'
    ELSE '12- out_of_funnel'
  END AS level_label
FROM last_step;

