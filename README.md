## Game Analytics: Professional Data Engineering Pipeline



This repository contains a **production-grade, end-to-end analytics pipeline** for a mobile Free‑to‑Play (F2P) game.  
It implements a **Medallion Architecture**, **strong data quality controls**, and a **polyglot (SQL + Python) feature store** to turn raw event logs into trustworthy datasets for:
- **A/B test analysis**
- **Funnel and retention analysis**
- **Revenue / ROAS analysis**
- **Player segmentation and ML features**

> **Status**: My raw data include only two dates (Jan 1 and Feb 1), so I could not add retention metrics due to lack of data.

> **Note**: The sample data used here is custom generated using `adhoc/main-dataset/generate_game_events.py` 

---

## Medallion Architecture & Data Flow

The pipeline follows a layered Medallion Architecture with a single source of truth:

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
```

---

## Data Model & Events

**Core event types**
- `install`: First installation of the game
- `tutorial_complete`: Tutorial completion
- `level_complete`: Level completion (with `level`)
- `session_start`: Session start
- `purchase`: Purchase event (with `revenue`)

**Key fields**
- `player_id` – unique player identifier
- `event_time` – event timestamp
- `event_name` – event type
- `session_id` – session identifier
- `level` – level number (nullable)
- `revenue` – revenue amount (float)
- `experiment_id` – A/B test identifier
- `variant` – A/B variant (e.g. `control`, `treatment`)

**Derived fields (Silver layer)**
- `dt` – event date
- `event_hour` – event hour
- `event_day` – event day
- `loaded_at` – load timestamp

---

## Feature Store: `python_analytics.player_features`

File: `game-data/assets/python_analytics/player_features.py`

This asset:
- Uses a SQL CTE pipeline on top of `gamedata.gamedata`
- Aggregates to player‑level metrics
- Is materialized as a table with `create+replace` strategy in Bruin
- Enforces data quality checks on the most critical columns:
  - `player_id` – `not_null`
  - `total_revenue` – `non_negative`
  - `days_active` – `positive`
  - `install_date` – `not_null`


The resulting table is suitable as:
- Input for BI dashboards
- Input for ML workflows (e.g., churn or LTV prediction)

---

## Dashboards & Analytics Views

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

---

## Technology Stack

- **Orchestration**: `Bruin` (dependencies, materialization, validation)
- **Warehouse**: Google BigQuery (`game-data-483711`)
- **Languages**: SQL (BigQuery dialect) and Python
- **Libraries** (see `requirements.txt`):
  - `pandas`, `numpy`
  - `google-cloud-bigquery`, `pyarrow`, `db-dtypes`
  - `pyyaml`, `scipy`
- **Authentication**: Google Cloud Service Account (see `keys/`)

---

## Project Structure (High Level)

```text
GameAnalyze/
├─ adhoc/
│  └─ main-dataset/
│     └─ generate_game_events.py       # Synthetic event generator
├─ game-data/
│  ├─ pipeline.yml                     # Bruin pipeline definition
│  └─ assets/
│     ├─ dashboard/
│     │  ├─ experiment_summary.sql     # Gold A/B test view
│     │  └─ player_with_events.sql     # Gold funnel view
│     ├─ gamedata/
│     │  └─ gamedata.sql               # Filtered / curated data
│     ├─ gamedata_raw/
│     │  └─ gamedata.asset.yml         # Raw ingestion (Google Sheets → BQ)
│     ├─ gamedata_staging/
│     │  └─ gamedata.sql               # Silver cleansing layer
│     ├─ helpers/
│     │  └─ helpers.py                 # BigQuery client helper
│     └─ python_analytics/
│        └─ player_features.py         # Feature store (Advanced Silver)
├─ keys/
│  ├─ creds_example.json               # Example credentials structure
│  └─ my_creds.json                    # Real credentials (gitignored)
├─ logs/                               # Logs (if enabled)
├─ game_events.csv                     # Generated synthetic events
├─ PROJE_OZETI.txt                     # Detailed Turkish project summary
├─ README.md                           # This file
└─ requirements.txt                    # Python dependencies
```

---

## Setup & Prerequisites

### 1. Google Cloud / BigQuery

- Create or use an existing GCP project (here referenced as `game-data-483711`).
- Enable the **BigQuery API**.
- Create a **Service Account** with BigQuery read/write permissions.
- Download the service account key JSON.

### 2. Credentials

You can provide credentials to Bruin via the environment variable `GOOGLE_CLOUD_CREDENTIALS`.  
`game-data/assets/helpers/helpers.py` expects this variable to contain either:
- A raw service account JSON, or
- A wrapper JSON with a `service_account_json` field.

Minimal example:

```bash
export GOOGLE_CLOUD_CREDENTIALS='{"type": "service_account", "...": "..."}'
```

Alternatively, you can follow the pattern in `keys/creds_example.json` and store the actual key as `keys/my_creds.json` (this file is gitignored).

### 3. Local Python Environment

```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

---

## Running the Pipeline

The pipeline is defined in `game-data/pipeline.yml`:
- **Name**: `game-analytics-pipeline`
- **Schedule**: daily
- **Default connection**: `game-data` (GCP)

High‑level steps to run it:
1. Configure Bruin according to the official documentation.
2. Register the `game-data` connection to point at your BigQuery project.
3. Ensure `GOOGLE_CLOUD_CREDENTIALS` is set in the environment where Bruin runs.
4. Trigger the pipeline (via Bruin CLI / UI / scheduler) so that assets are materialized in order:
   - `gamedata_raw.gamedata`
   - `gamedata_staging.gamedata`
   - `gamedata.gamedata`
   - `python_analytics.player_features`
   - `dashboard.experiment_summary`

---

## Synthetic Data Generation (Adhoc)

File: `adhoc/main-dataset/generate_game_events.py`

This script can be used to generate a realistic synthetic dataset:
- ~20,000 simulated players
- Control vs treatment variants
- Tutorial completion probabilities (different by variant)
- Retention probabilities (D1, D7, D30)
- Purchase probabilities and discrete price points (e.g. 1.99, 4.99, 9.99)

Output:
- `game_events.csv` at the project root, which can be ingested into the pipeline for experimentation and demos.

---

## Data Quality & Defensive Engineering

The project uses Bruin’s native validation checks to guarantee reliability:

- **Uniqueness**
  - E.g. `player_id` integrity in the feature store.
- **Sanity ranges**
  - `revenue` is checked for non‑negative values.
  - `days_active` is checked to be positive.
- **Completeness**
  - `not_null` constraints on critical keys and timestamps.
- **Defensive SQL**
  - Extensive usage of `SAFE_DIVIDE`, `NULLIF`, `COALESCE` to avoid runtime failures on missing or extreme values.

If validations fail, the pipeline follows a **fail‑fast** philosophy so that data issues are visible early.

---

## Security & Configuration

- Real credentials are never committed:
  - `keys/my_creds.json` is excluded via `.gitignore`.
  - `keys/creds_example.json` documents the expected structure.
- The `connection` configuration `game-data` in `pipeline.yml` should reference your secure GCP connection.
- Always scope service account permissions to the minimum required for the BigQuery datasets used by this pipeline.

---

## Example Use Cases

- **A/B Test Analysis**
  - Use `dashboard.experiment_summary` to compare control vs treatment on engagement and revenue.
- **Player Segmentation**
  - Use `python_analytics.player_features` for RFM‑style analysis or clustering.
- **Funnel Analysis**
  - Use `dashboard.player_with_events` for stage‑level funnel and progression.
- **Financial Analytics**
  - ARPU / ARPPU, conversion rate, and revenue trends across experiments.

---

## What I Learned From This Project

- **Applying the Medallion Architecture in Practice**: By building out the Bronze → Silver → (Advanced) Silver → Gold layers end-to-end, I experienced firsthand how critical it is to maintain a Single Source of Truth (SSOT) for both data quality and low maintenance costs.
- **Orchestrating Data with Bruin**: I learned how to manage both SQL and Python assets within a single pipeline, define their dependencies, and enforce data quality rules at the pipeline level using Bruin.
- **Professional SQL Design on BigQuery**: I strengthened my skills in designing defensive SQL using patterns like `SAFE_DIVIDE`, `NULLIF`, and `COALESCE` to safely conduct A/B test, funnel, and revenue analyses.
- **The Feature Store Concept**: I saw how bringing together player-level metrics (sessions, revenue, retention proxies, etc.) into a reusable **feature store** table can empower both BI analytics and future ML projects (like churn or LTV prediction).
- **The Power of the Semantic Layer in Dashboard Design**: I learned that moving business logic from Looker Studio into the data warehouse, making the visualization layer just a “thin presentation layer”, provides huge benefits for maintainability and the end-user experience.

# Game Analytics: Professional Data Engineering Pipeline


A production-grade, end-to-end data pipeline designed for a mobile Free-to-Play (F2P) game. This project focuses on **Engineering Robustness**, **Data Quality**, and the **Medallion Architecture** to transform raw event logs into high-integrity datasets ready for A/B testing and financial analysis.

---

## 🏗 Medallion Architecture & Data Flow

The pipeline is architected across four distinct layers to ensure a clean "Single Source of Truth" (SSOT):

1.  **🥉 Bronze (Raw Ingestion)**:
    *   **Logic**: High-fidelity ingestion from source (Google Sheets) directly to BigQuery.
    *   **Value**: Maintains a permanent, immutable audit trail of raw data.
2.  **🥈 Silver (Consolidation & Cleansing)**:
    *   **Logic**: Modular SQL assets (`gamedata_staging`) that standardize schemas, handle type casting, and perform mechanical cleansing (TRIM/LOWER/NULL handling).
    *   **Value**: Provides a reliable foundation for all downstream analytical models.
3.  **🥇 Advanced Silver (Feature Store - Python)**:
    *   **Logic**: A **Polyglot Asset** combining SQL for heavy computation and **Python (Pandas)** for complex behavioral aggregation.
    *   **Value**: Transforms granular logs into player-centric profiles (ARPU, sessions, residency), serving as a reusable Feature Store for ML and BI.
4.  **💎 Gold (Semantic Layer)**:
    *   **Logic**: Implements a self-contained analytics view (`experiment_summary`) with automated **A/B Test Lift** and **ROAS** calculations performed at the database level.
    *   **Value**: Decouples business logic from visualization tools, ensuring "Zero-SQL" requirement for business stakeholders.

---

## 🚀 Engineering Highlights

### 🐍 Polyglot Pipeline Engineering
Instead of a pure SQL approach, this pipeline utilizes **Python-integrated assets** within the Bruin orchestrator. This allows for:
- **Matrix-style aggregations** that are difficult to manage in pure SQL.
- **Pythonic Testing**: Integration of custom logic for financial simulation (CPI/ROAS).
- **ML Readiness**: The output of the Advanced Silver layer is directly consumable by Scikit-learn or PyTorch for future Churn/LTV prediction.

### ✅ Automated Data Quality (DQ) Guardrails
Engineering for reliability means "failing fast." The pipeline is guarded by **Bruin Native Validation Checks**:
- **Uniqueness**: Ensuring `player_id` integrity at the feature level.
- **Sanity Ranges**: `non_negative` checks on revenue and `positive` checks on engagement metrics.
- **Completeness**: `not_null` constraints on critical join keys and timestamps.

### 🧬 Professional SQL Patterns
The Gold layer utilizes advanced SQL concepts for scalability:
- **Self-Joins & Union Patterns**: Automated comparison of A/B test variants against the control group.
- **Defensive SQL**: Widespread use of `SAFE_DIVIDE`, `NULLIF`, and `COALESCE` to prevent pipeline crashes on outlier or missing data.

---

## 🛠 Technology Stack

- **Orchestration**: [Bruin](https://getbruin.com/) (Managing dependencies, materializations, and validations)
- **Data Warehouse**: Google BigQuery
- **Feature Engineering**: Python (Pandas)
- **Data Modeling**: SQL (Modular BigQuery dialect)
- **Validation**: Bruin DQ Framework


