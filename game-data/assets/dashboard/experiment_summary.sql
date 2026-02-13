/* @bruin
name: dashboard.experiment_summary
type: bq.sql
materialization:
    type: table

depends:
  - python_analytics.player_features
@bruin */

WITH metrics AS (
    SELECT
        experiment_id,
        variant,
        COUNT(*) AS total_players,
        AVG(days_active) AS avg_days_active,
        AVG(total_sessions) AS avg_sessions,
        COUNTIF(has_purchase) AS buyers,
        SAFE_DIVIDE(COUNTIF(has_purchase), COUNT(*)) AS conversion_rate,
        SUM(total_revenue) AS total_revenue,
        SAFE_DIVIDE(SUM(total_revenue), COUNT(*)) AS arpu,
        SAFE_DIVIDE(SUM(total_revenue), COUNTIF(has_purchase)) AS arppu,
        SAFE_DIVIDE(COUNTIF(days_active > 1), COUNT(*)) AS retention_rate
    FROM python_analytics.player_features
    GROUP BY 1,2
),
delta AS (
    SELECT
        t.experiment_id,
        'absolute_delta' AS variant,

        t.total_players - c.total_players AS total_players,
        t.avg_days_active - c.avg_days_active AS avg_days_active,
        t.avg_sessions - c.avg_sessions AS avg_sessions,
        t.buyers - c.buyers AS buyers,
        t.conversion_rate - c.conversion_rate AS conversion_rate,
        t.total_revenue - c.total_revenue AS total_revenue,
        t.arpu - c.arpu AS arpu,
        t.arppu - c.arppu AS arppu,
        t.retention_rate - c.retention_rate AS retention_rate
    FROM metrics t
    JOIN metrics c
      ON t.experiment_id = c.experiment_id
     AND c.variant = 'control'
    WHERE t.variant != 'control'
)
SELECT *
FROM (
    SELECT * FROM metrics
    UNION ALL
    SELECT * FROM delta
)
ORDER BY
    experiment_id,
    CASE variant
        WHEN 'control' THEN 1
        WHEN 'treatment' THEN 2
        WHEN 'absolute_delta' THEN 3
    END;
