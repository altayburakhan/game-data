""" @bruin
name: python_analytics.player_features
type: python
description: "I only added  these columns to the data quality checks. Because of the most critical data points for the analysis. I dont add Primary key for this because i use crate and replace strategy it deletes and create table everytime. "
materialization:
  type: table
  strategy: create+replace
connection: game-data
depends:
  - gamedata.gamedata

columns:
  - name: player_id
    type: string
    description: Unique identifier for the player
    checks:
      - name: not_null
  - name: total_revenue
    type: float
    description: Total lifetime revenue of the player
    checks:
      - name: non_negative
  - name: days_active
    type: integer
    description: Number of unique days the player was active
    checks:
      - name: positive
  - name: install_date
    type: date
    description: Date when the player installed the game
    checks:
      - name: not_null
@bruin """

import os
import pandas as pd
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../')))

from helpers.helpers import get_bq_client

FEATURE_QUERY = """
WITH base_events AS (
  SELECT
    player_id,
    event_name,
    event_time,
    dt,
    level,
    revenue,
    experiment_id,
    variant
  FROM `game-data-483711.gamedata.gamedata`
),
player_installs AS (
  SELECT
    player_id,
    ANY_VALUE(variant) AS variant,
    ANY_VALUE(experiment_id) AS experiment_id,
    MIN(CASE WHEN event_name = 'install' THEN dt END) AS install_date
  FROM base_events
  GROUP BY player_id
),
player_activity AS (
  SELECT
    player_id,
    COUNT(*) AS total_events,
    COUNTIF(event_name = 'session_start') AS total_sessions,
    COUNTIF(event_name = 'purchase') AS purchase_events,
    SUM(COALESCE(revenue, 0)) AS total_revenue,
    MAX(COALESCE(level, 0)) AS max_level,
    COUNT(DISTINCT dt) AS days_active,
    MIN(event_time) AS first_event_time,
    MAX(event_time) AS last_event_time
  FROM base_events
  GROUP BY player_id
)
SELECT
  i.player_id,
  i.variant,
  i.experiment_id,
  i.install_date,
  a.total_events,
  a.total_sessions,
  a.purchase_events,
  a.total_revenue,
  a.max_level,
  a.days_active,
  a.first_event_time,
  a.last_event_time,
  CASE WHEN a.purchase_events > 0 THEN TRUE ELSE FALSE END AS has_purchase,
  CASE
    WHEN a.days_active > 0 THEN a.total_events / a.days_active
    ELSE 0
  END AS avg_events_per_active_day
FROM player_installs i
LEFT JOIN player_activity a
  ON i.player_id = a.player_id
"""

def materialize():
    print(" [Feature Store] Starting extraction...")
    client = get_bq_client()
    
    df = client.query(FEATURE_QUERY).to_dataframe()
    
    print(f" Extracted & Transformed {len(df)} rows.")
    print(" Returning DataFrame to Bruin for materialization...")
    return df
