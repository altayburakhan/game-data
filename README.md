# Game Analytics Pipeline

An end-to-end data engineering project built for a mobile Free-to-Play (F2P) game. It ingests raw player events, transforms them through a layered architecture, and delivers analytics-ready datasets for A/B testing, funnel analysis, and player segmentation.

> **Note:** The dataset used in this project is synthetically generated via `adhoc/main-dataset/generate_game_events.py` — simulating 20,000 players across a controlled A/B experiment.

---

## Architecture: Medallion Layers

The pipeline follows a Bronze → Silver → Gold architecture orchestrated by [Bruin](https://getbruin.com/), running on Google BigQuery.

```
Google Sheets (raw events)
        ↓
[Bronze]  gamedata_raw.gamedata         — immutable ingestion
        ↓
[Silver]  gamedata_staging.gamedata     — normalization & type casting
        ↓
[Silver]  gamedata.gamedata             — quality-filtered clean table
        ↓
[Python]  python_analytics.player_features  — player-level feature store
        ↓
[Gold]    dashboard.experiment_summary  — A/B test metrics & lift
[Gold]    dashboard.player_with_events  — funnel progression per player
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
