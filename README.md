# Game Analytics & A/B Testing Pipeline

A production-grade Data Engineering pipeline designed to process mobile F2P game events, following the **Medallion Architecture**. This project matures raw event data into a high-value **Feature Store** and a **Semantic Layer** for A/B testing analysis.

---

## 🏗 Architecture Overview

The pipeline implements a progressive data refinement strategy across four distinct layers:

1.  **🥉 Bronze (Raw)**: Ingests raw event logs from Google Sheets into BigQuery using Bruin's ingestion capabilities.
2.  **🥈 Silver (Staging & Clean)**: Standardizes schemas, performs type casting, and cleanses data (handling NULLs, casing, and white-spaces) via modular SQL assets.
3.  **🥇 Advanced Silver (Feature Store)**: A **Python (Pandas/BigQuery)** based asset that aggregates granular events into player-centric profiles. It calculates over 10+ behavioral and monetization metrics (ARPU, sessions, active days, etc.), serving as a foundation for both BI and Machine Learning.
4.  **💎 Gold (Semantic Layer)**: A final materialization (`experiment_summary`) that pre-calculates core KPIs and automated **A/B Test Lift (Delta)** metrics. This layer is optimized for direct consumption by Looker Studio.

---

## 🛠 Tech Stack

- **Orchestration**: [Bruin](https://getbruin.com/) (Pipeline management, validation, and execution)
- **Engine**: Google BigQuery
- **Languages**: SQL & Python (Pandas)
- **Validation**: Bruin Native DQ Checks (Unique, Not-Null, Non-Negative)
- **Visualization**: Looker Studio

---

## 🚀 Key Engineering Features

- **Polyglot Pipeline**: Combines the efficiency of SQL Pushdown for heavy lifting with the flexibility of Python for feature engineering.
- **Automated Data Quality**: Every pipeline run is guarded by automated checks ensuring data integrity before reaching the dashboard.
- **Self-Service Analytics**: Business stakeholders can access pre-calculated A/B test results (Lift/Delta) without writing a single line of SQL.
- **User Funnel Modeling**: Includes specific logic to track user progression through game levels/tutorials to identify drop-off points.

---

## 📊 Business Insights

The pipeline was used to analyze the `tutorial_v2_test`, revealing:
- **ARPU Lift**: **+200%** increase in average revenue per user in the treatment group.
- **Conversion Lift**: **+87%** increase in the ratio of paying users.
- **Data Significance**: Processed ~20,000 unique players with balanced variant distribution, ensuring statistical reliability.

---
<img width="1120" height="679" alt="image" src="https://github.com/user-attachments/assets/9e519164-64c8-4348-99a7-f4f7b19f6f39" />
<img width="1076" height="205" alt="image" src="https://github.com/user-attachments/assets/a9723b00-836f-43b5-b778-cbc21a8a3929" />


## ⚙️ How to Run

1.  **Validate**: Run `bruin validate` to check pipeline health and data quality definitions.
2.  **Execute**: Run `bruin run` to process the entire pipeline from raw ingestion to the final analytics table.

---

> **Data Engineer Note**: This project demonstrates the full lifecycle of data engineering—from raw ingestion and quality assurance to advanced feature modeling and executive reporting.
