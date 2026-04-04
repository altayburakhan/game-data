# Game Analytics Pipeline

An end-to-end data engineering project built for a mobile Free-to-Play (F2P) game. It ingests raw player events, transforms them through a layered architecture, and delivers analytics-ready datasets for A/B testing, funnel analysis, and player segmentation.

> **Status:**  My raw data include only two dates (Jan 1 and Feb 1), so I could not add retention metrics due to lack of data.

> **Note:** The sample data used here is custom generated using adhoc/main-dataset/generate_game_events.py

---

## Architecture: Medallion Layers

The pipeline follows a Bronze → Silver → Gold architecture orchestrated by [Bruin](https://getbruin.com/), running on Google BigQuery.

```
Google Sheets (raw events)
        ↓
[Bronze]  gamedata_raw.gamedata              — immutable ingestion
        ↓
[Silver]  gamedata_staging.gamedata          — normalization & type casting
        ↓
[Silver]  gamedata.gamedata                  — quality-filtered clean table
        ↓
[Python]  python_analytics.player_features   — player-level feature store
        ↓
[Gold]    dashboard.experiment_summary       — A/B test metrics & lift
[Gold]    dashboard.player_with_events       — funnel progression per player
```

---

## What Each Layer Does

**Bronze** — Raw data ingested from Google Sheets with no transformation. Serves as an immutable audit trail.

**Silver** — Applies schema standardization, `LOWER`/`TRIM` normalization, `SAFE_CAST` type conversions, and derives fields like `dt`, `event_hour`, and `loaded_at`. NULL and invalid rows are filtered at this stage.

**Feature Store (Python)** — A polyglot Bruin asset that runs SQL aggregations in BigQuery and returns results via Pandas. Produces a player-level table with:
- Engagement: `total_events`, `total_sessions`, `days_active`, `avg_events_per_active_day`
- Monetization: `total_revenue`, `purchase_events`, `has_purchase`
- Progression: `max_level`, `install_date`
- Experiment context: `experiment_id`, `variant`

**Gold (Dashboards)** — Business-ready tables consumed directly by Looker Studio:
- `experiment_summary`: Compares control vs. treatment across ARPU, ARPPU, conversion rate, retention, and sessions — including an `absolute_delta` lift row computed via self-join.
- `player_with_events`: Maps each player to their furthest funnel stage (install → tutorial → level 1–10), one row per player.

---

## Data Quality

Bruin native validation checks are enforced on the feature store:

| Column | Check |
|---|---|
| `player_id` | `not_null` |
| `total_revenue` | `non_negative` |
| `days_active` | `positive` |
| `install_date` | `not_null` |
| `player_id` (Gold) | `unique`, `not_null` |
| `variant` (Gold) | `accepted_values` |

Defensive SQL patterns (`SAFE_DIVIDE`, `COALESCE`, `SAFE_CAST`) prevent runtime failures on missing or extreme values.

---

## Dashboards

### Player Funnel — `dashboard.player_with_events`

[View in Looker Studio](https://lookerstudio.google.com/reporting/2c9f1083-ea12-440f-9901-ae17fb9e29ec)

<img width="1196" height="553" alt="Player funnel dashboard" src="https://github.com/user-attachments/assets/e7035542-984f-4ba9-9156-b8659e56cd0a" />

### A/B Test Summary — `dashboard.experiment_summary`

[View in Looker Studio](https://lookerstudio.google.com/reporting/8cc25a59-6f74-41bd-b87b-27d574a1c54d)

<img width="1136" height="142" alt="Experiment summary dashboard" src="https://github.com/user-attachments/assets/61d84f63-1a60-42e3-aec0-53040b9bfb36" />

### Pipeline (Bruin)

<img width="1379" height="322" alt="Bruin pipeline graph" src="https://github.com/user-attachments/assets/66ab6004-7a72-412b-bc33-e8998739a8d5" />

Scheduled to run three times a day (00:00, 08:00, 16:00 UTC):

<img width="1384" height="578" alt="Bruin schedule" src="https://github.com/user-attachments/assets/d77f5af0-2b70-4636-904f-8d2dc3de4592" />

---

## Tech Stack

| Tool | Role |
|---|---|
| [Bruin](https://getbruin.com/) | Pipeline orchestration, dependency management, DQ validation |
| Google BigQuery | Data warehouse |
| Python / Pandas | Feature engineering (polyglot asset) |
| SQL (BigQuery dialect) | Transformation & analytics logic |
| Google Sheets | Raw data source (via ingestr) |
| Looker Studio | Dashboard visualization |

---

## Project Structure

```
GameAnalyze/
├── adhoc/main-dataset/
│   └── generate_game_events.py      # Synthetic data generator
├── game-data/
│   ├── pipeline.yml                 # Bruin pipeline definition
│   └── assets/
│       ├── gamedata_raw/            # Bronze: raw ingestion
│       ├── gamedata_staging/        # Silver: normalization
│       ├── gamedata/                # Silver: quality filter
│       ├── python_analytics/        # Feature store (Python)
│       ├── dashboard/               # Gold: BI-ready tables
│       └── helpers/                 # BigQuery client utility
├── game_events.csv                  # Generated synthetic dataset
└── requirements.txt
```

---

## Key Learnings

- **Medallion Architecture in practice** — building Bronze → Silver → Gold end-to-end reinforced how layer separation protects data integrity and reduces maintenance costs.
- **Polyglot pipelines** — combining SQL and Python within a single orchestrated asset unlocks flexibility without sacrificing structure.
- **Semantic layer design** — moving business logic (A/B lift calculations, funnel mapping) into the warehouse makes BI tools thin presentation layers, not logic owners.
- **Fail-fast data quality** — enforcing checks at the pipeline level, not the dashboard level, catches issues early and builds stakeholder trust.
