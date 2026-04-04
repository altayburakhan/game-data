# Game Analytics Pipeline

An end-to-end data engineering project built for a mobile Free-to-Play (F2P) game. It ingests raw player events, transforms them through a layered architecture, and delivers analytics-ready datasets for A/B testing, funnel analysis, and player segmentation.

<<<<<<< HEAD
> **Note:** The dataset used in this project is synthetically generated via `adhoc/main-dataset/generate_game_events.py` — simulating 20,000 players across a controlled A/B experiment.
=======

This repository contains a **production-grade, end-to-end analytics pipeline** for a mobile Free‑to‑Play (F2P) game.  
It implements a **Medallion Architecture**, **strong data quality controls**, and a **polyglot (SQL + Python) feature store** to turn raw event logs into trustworthy datasets for:
- **A/B test analysis**
- **Funnel and retention analysis**
- **Player segmentation and ML features**

> **Status**: My raw data include only two dates (Jan 1 and Feb 1), so I could not add retention metrics due to lack of data.

> **Note**: The sample data used here is custom generated using `adhoc/main-dataset/generate_game_events.py` 
>>>>>>> a37f3157ec39058a5cee4e1d9ab9f3f3632b45f2

---

## Architecture: Medallion Layers

The pipeline follows a Bronze → Silver → Gold architecture orchestrated by [Bruin](https://getbruin.com/), running on Google BigQuery.

<<<<<<< HEAD
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
=======
1. **Bronze – Raw Ingestion**
   - **Asset**: `game-data/assets/gamedata_raw/gamedata.asset.yml`
   - **Source**: Google Sheets → BigQuery
   - **Purpose**: Immutable, high‑fidelity copy of the raw game events (audit trail).

2. **Silver – Consolidation & Cleansing**
   - **Assets**:
     - `game-data/assets/gamedata_staging/gamedata.sql`
     - `game-data/assets/gamedata/gamedata.sql`
   - **Logic**:
     - Schema standardization and type casting (including `SAFE_CAST`)
     - Mechanical cleaning (`TRIM`, `LOWER`, NULL handling`)
     - Derivation of core technical fields such as `dt`, `event_hour`, `event_day`, `loaded_at`
   - **Purpose**: Reliable base tables for all downstream analytics.

3. **Advanced Silver – Feature Store (Python)**
   - **Asset**: `game-data/assets/python_analytics/player_features.py`
   - **Type**: Bruin polyglot asset (SQL + Python / Pandas)
   - **Input**: `gamedata.gamedata` (Silver)
   - **Output**: Player‑level feature store with:
     - `total_events`, `total_sessions`, `purchase_events`
     - `total_revenue`, `max_level`, `days_active`
     - `has_purchase`, `avg_events_per_active_day`
     - Experiment context: `experiment_id`, `variant`, `install_date`

4. **Gold – Semantic Layer (Dashboards)**
   - **Assets**:
     - `game-data/assets/dashboard/experiment_summary.sql`
     - `game-data/assets/dashboard/player_with_events.sql`
   - **`experiment_summary`**:
     - A/B test metrics and lift calculations
     - Metrics like `total_players`, `buyers`, `conversion_rate`, `ARPU`, `ARPPU`, `avg_days_active`, `avg_sessions`, `retention_rate`
   - **`player_with_events`**:
     - Funnel‑oriented view of each player’s latest step
     - Stage tracking such as install → tutorial → level 1–10

**Data flow**

```text
Google Sheets
    ↓
[Bronze] gamedata_raw.gamedata
    ↓
[Silver] gamedata_staging.gamedata
    ↓
[Silver] gamedata.gamedata
    ↓
[Advanced Silver] python_analytics.player_features
    ↓
[Gold] dashboard.experiment_summary
    ↓
[Gold] dashboard.player_with_events
>>>>>>> a37f3157ec39058a5cee4e1d9ab9f3f3632b45f2
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

<<<<<<< HEAD
| Tool | Role |
|---|---|
| [Bruin](https://getbruin.com/) | Pipeline orchestration, dependency management, DQ validation |
| Google BigQuery | Data warehouse |
| Python / Pandas | Feature engineering (polyglot asset) |
| SQL (BigQuery dialect) | Transformation & analytics logic |
| Google Sheets | Raw data source (via ingestr) |
| Looker Studio | Dashboard visualization |
=======
### `dashboard.experiment_summary`

**File**: `game-data/assets/dashboard/experiment_summary.sql`

Provides a self‑contained A/B testing view:
- Compares `variant` groups (e.g. control vs treatment)
- Computes:
  - `total_players`, `buyers`
  - `conversion_rate`
  - `total_revenue`, `ARPU`, `ARPPU`
  - Retention‑style metrics such as `avg_days_active`, `avg_sessions`
- Includes lift / delta metrics between treatment and control

### `dashboard.player_with_events`

**File**: `game-data/assets/dashboard/player_with_events.sql`

Provides a funnel‑oriented view:
- Latest funnel step of each player (`last_step`)
- Level labels (e.g. install, tutorial_complete, early levels)
- Useful for conversion funnel and progression analysis

### Looker Studio Dashboard Preview

This semantic layer is visualized in **Looker Studio** to provide an end‑to‑end, no‑SQL analytics experience for stakeholders.  
The main dashboard includes:
- **Install → level progression funnel**
- **Tutorial and early‑level completion rates**
- **Variant‑based comparison for key metrics (conversion, revenue, progression)**

Dashboard previews:
player_with_events.sql (LINK : https://lookerstudio.google.com/reporting/2c9f1083-ea12-440f-9901-ae17fb9e29ec):

<img width="1196" height="553" alt="Screenshot 2026-03-03 000539" src="https://github.com/user-attachments/assets/e7035542-984f-4ba9-9156-b8659e56cd0a" />

experiment_summary.sql (LINK : https://lookerstudio.google.com/reporting/8cc25a59-6f74-41bd-b87b-27d574a1c54d):

<img width="1136" height="142" alt="image" src="https://github.com/user-attachments/assets/61d84f63-1a60-42e3-aec0-53040b9bfb36" />


My Pipeline (Bruin)

<img width="1379" height="322" alt="image" src="https://github.com/user-attachments/assets/66ab6004-7a72-412b-bc33-e8998739a8d5" />

I set it three times a day

<img width="1384" height="578" alt="image" src="https://github.com/user-attachments/assets/d77f5af0-2b70-4636-904f-8d2dc3de4592" />
>>>>>>> a37f3157ec39058a5cee4e1d9ab9f3f3632b45f2

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
