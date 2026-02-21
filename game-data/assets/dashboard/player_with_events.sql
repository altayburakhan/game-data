/* @bruin
name: dashboard.player_with_events
type: bq.sql
description: >
  Gold layer funnel table showing each player's furthest reached stage in the game.
  Maps install → tutorial_complete → level_1..10_completed into a numeric stage,
  then picks the single highest stage per player (last_step) using a window function.
  Designed for funnel/drop-off analysis in BI tools. One row per player.

materialization:
  type: table
  strategy: create+replace

depends:
  - gamedata.gamedata

columns:
  - name: player_id
    type: string
    description: Unique identifier for the player
    checks:
      - name: not_null
      - name: unique
  - name: level
    type: integer
    description: "Numeric stage the player last reached: 0=install, 1=tutorial, 2-11=level 1-10"
  - name: last_stage_time
    type: timestamp
    description: Timestamp of the event where the player reached their highest stage
  - name: event_date
    type: date
    description: Date of the last stage event
  - name: level_label
    type: string
    description: Human-readable label for the stage (e.g. '2- level_1_completed')
@bruin */

-- ============================================================
-- STEP 1: Assign a numeric stage to each event.
-- install=0, tutorial_complete=1, level_complete=1+level.
-- Other events (session_start, purchase) produce NULL stage
-- and are naturally excluded by the window function in step 2.
-- ============================================================
WITH events_with_stage AS (
  SELECT
    player_id,
    event_time,
    dt AS event_date,
    CASE
      WHEN event_name = 'install'           THEN 0
      WHEN event_name = 'tutorial_complete' THEN 1
      WHEN event_name = 'level_complete'    THEN 1 + level
    END AS stage
  FROM gamedata.gamedata
),

-- ============================================================
-- STEP 2: Pick the single highest stage per player.
-- Tie-break: if two events share the same stage, take the
-- earliest event_time (first occurrence of that milestone).
-- ============================================================
last_step AS (
  SELECT
    player_id,
    stage AS level,
    event_time AS last_stage_time,
    event_date
  FROM events_with_stage
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY player_id
    ORDER BY stage DESC, event_time ASC
  ) = 1
)

-- ============================================================
-- STEP 3: Attach a human-readable label for BI consumption.
-- ============================================================
SELECT
  player_id,
  level,
  last_stage_time,
  event_date,
  CASE level
    WHEN 0  THEN '0- install'
    WHEN 1  THEN '1- tutorial_complete'
    WHEN 2  THEN '2- level_1_completed'
    WHEN 3  THEN '3- level_2_completed'
    WHEN 4  THEN '4- level_3_completed'
    WHEN 5  THEN '5- level_4_completed'
    WHEN 6  THEN '6- level_5_completed'
    WHEN 7  THEN '7- level_6_completed'
    WHEN 8  THEN '8- level_7_completed'
    WHEN 9  THEN '9- level_8_completed'
    WHEN 10 THEN '10- level_9_completed'
    WHEN 11 THEN '11- level_10_completed'
    ELSE        '12- out_of_funnel'
  END AS level_label
FROM last_step;
