# Game Analytics Pipeline

An end-to-end data pipeline built around a synthetic mobile F2P game. Raw player events flow through a layered architecture and land in analytics-ready tables used for A/B testing, funnel tracking, and player segmentation.

The dataset is fully synthetic. I generated 20,000 simulated players using a custom Python script (`adhoc/main-dataset/generate_game_events.py`).

> **Note:** Raw data only covers two dates (Jan 1 and Feb 1), so retention metrics couldn't be included due to insufficient data.

---

## Pipeline

Orchestrated by [Bruin](https://getbruin.com/), running on Google BigQuery.

```
Google Sheets (raw events)
        ↓
[Bronze]  gamedata_raw        — raw ingestion, no transforms
        ↓
[Silver]  gamedata_staging    — type casting, normalization
        ↓
[Silver]  gamedata            — quality-filtered clean table
        ↓
[Python]  player_features     — player-level feature store
        ↓
[Gold]    experiment_summary  — A/B test metrics & lift
[Gold]    player_with_events  — funnel progression per player
```

Bronze keeps an immutable copy of everything. Silver cleans and standardizes it. The Python asset aggregates player-level features. Gold tables go straight to Looker Studio.

---

## Dashboards

### Player Funnel

[View in Looker Studio](https://lookerstudio.google.com/reporting/2c9f1083-ea12-440f-9901-ae17fb9e29ec)

<img width="1196" height="553" alt="Player funnel dashboard" src="https://github.com/user-attachments/assets/e7035542-984f-4ba9-9156-b8659e56cd0a" />

### A/B Test Summary

[View in Looker Studio](https://lookerstudio.google.com/reporting/8cc25a59-6f74-41bd-b87b-27d574a1c54d)

<img width="1136" height="142" alt="Experiment summary dashboard" src="https://github.com/user-attachments/assets/61d84f63-1a60-42e3-aec0-53040b9bfb36" />

### Bruin Pipeline

<img width="1379" height="322" alt="Bruin pipeline graph" src="https://github.com/user-attachments/assets/66ab6004-7a72-412b-bc33-e8998739a8d5" />

Runs three times a day (00:00, 08:00, 16:00 UTC):

<img width="1384" height="578" alt="Bruin schedule" src="https://github.com/user-attachments/assets/d77f5af0-2b70-4636-904f-8d2dc3de4592" />

---

## Tech Stack

| Tool | Role |
|---|---|
| [Bruin](https://getbruin.com/) | Pipeline orchestration & data quality |
| Google BigQuery | Data warehouse |
| Python / Pandas | Feature engineering |
| Google Sheets | Raw data source |
| Looker Studio | Dashboards |

---

## Project Structure

```
GameAnalyze/
├── adhoc/main-dataset/
│   └── generate_game_events.py
├── game-data/
│   ├── pipeline.yml
│   └── assets/
│       ├── gamedata_raw/         # Bronze
│       ├── gamedata_staging/     # Silver
│       ├── gamedata/             # Silver (cleaned)
│       ├── python_analytics/     # Feature store
│       └── dashboard/            # Gold
└── requirements.txt
```
