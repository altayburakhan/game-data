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
<<<<<<< HEAD
## 📉 Looker Studio Dashboards

### 1. User Progression & Funnel Analysis
*Powered by `player_with_events.sql`*

This dashboard visualizes the end-to-end user journey, identifying exactly where players drop off within the game funnel. By tracking the last event reached by each player, we can pinpoint specific levels or tutorial steps that cause friction, allowing for data-driven adjustments to the game's difficulty and onboarding flow.

<img width="1120" height="679" alt="User Progression Analysis" src="https://github.com/user-attachments/assets/9e519164-64c8-4348-99a7-f4f7b19f6f39" />

---

### 2. A/B Testing Executive Summary
*Powered by `experiment_summary.sql`*

A high-level view of the experiment performance, comparing control and treatment groups. The dashboard highlights key monetization and engagement KPIs, including pre-calculated **Lift** and **ROAS** metrics. This enables stakeholders to immediately see the financial impact of game changes and make definitive "go/no-go" decisions.

<img width="1076" height="205" alt="A/B Test Summary Dashboard" src="https://github.com/user-attachments/assets/a9723b00-836f-43b5-b778-cbc21a8a3929" />
=======
<img width="1120" height="679" alt="image" src="https://github.com/user-attachments/assets/9e519164-64c8-4348-99a7-f4f7b19f6f39" />
<img width="1129" height="151" alt="image" src="https://github.com/user-attachments/assets/9ef62e27-43b5-429b-8ffe-c25eb78be4fa" />
>>>>>>> 573efbfed8fe7ef0255a23b8f07d7bd7fc0f282f



## ⚙️ How to Run

1.  **Validate**: Run `bruin validate` to check pipeline health and data quality definitions.
2.  **Execute**: Run `bruin run` to process the entire pipeline from raw ingestion to the final analytics table.


