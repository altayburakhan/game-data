# Game Analytics: Professional Data Engineering Pipeline

> [!NOTE]
> **Work in Progress**: This project is currently under active development. The pipeline is being refined, and some components may not be fully executable in their current state.


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

---

> **Note**: This project serves as a demonstration of **Defensive Data Engineering**. It prioritizes data integrity and architectural modularity, ensuring that the final "Gold" data is trustable, scalable, and fully documented.
