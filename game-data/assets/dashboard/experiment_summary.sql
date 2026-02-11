/* @bruin
name: dashboard.experiment_summary
type: bq.sql
materialization:
    type: table

depends:
  - python_analytics.player_features
@bruin */

WITH variant_metrics AS (
    SELECT
        experiment_id,
        variant,
        COUNT(player_id) AS total_players,
        AVG(days_active) AS avg_days_active,
        AVG(total_sessions) AS avg_sessions_per_player,
        COUNTIF(has_purchase) AS paying_players,
        SAFE_DIVIDE(COUNTIF(has_purchase), COUNT(player_id)) AS conversion_rate,
        SUM(total_revenue) AS total_revenue,
        SAFE_DIVIDE(SUM(total_revenue), COUNT(player_id)) AS arpu,
        SAFE_DIVIDE(SUM(total_revenue), NULLIF(COUNTIF(has_purchase), 0)) AS arppu
    FROM python_analytics.player_features
    GROUP BY 1, 2
),
lift_calculation AS (
    SELECT
        v.experiment_id,
        'delta_lift' AS variant,
        -- We don't sum players for lift, but we can show the difference in sample size if needed. 
        -- Usually lift is for percentage/average metrics.
        v.total_players - c.total_players AS total_players, 
        
        SAFE_DIVIDE(v.avg_days_active - c.avg_days_active, c.avg_days_active) AS avg_days_active,
        SAFE_DIVIDE(v.avg_sessions_per_player - c.avg_sessions_per_player, c.avg_sessions_per_player) AS avg_sessions_per_player,
        v.paying_players - c.paying_players AS paying_players,
        SAFE_DIVIDE(v.conversion_rate - c.conversion_rate, c.conversion_rate) AS conversion_rate,
        v.total_revenue - c.total_revenue AS total_revenue,
        SAFE_DIVIDE(v.arpu - c.arpu, c.arpu) AS arpu,
        SAFE_DIVIDE(v.arppu - c.arppu, c.arppu) AS arppu
    FROM variant_metrics v
    JOIN variant_metrics c ON v.experiment_id = c.experiment_id
    WHERE v.variant != 'control' AND c.variant = 'control'
)

-- Final Output: Combine real variants and the calculated lift row
SELECT 
    experiment_id,
    variant,
    total_players,
    ROUND(avg_days_active, 2) AS avg_days_active,
    ROUND(avg_sessions_per_player, 2) AS avg_sessions_per_player,
    paying_players,
    ROUND(conversion_rate, 4) AS conversion_rate,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(arpu, 2) AS arpu,
    ROUND(arppu, 2) AS arppu
FROM (
    SELECT * FROM variant_metrics
    UNION ALL
    SELECT * FROM lift_calculation
)
ORDER BY experiment_id, (CASE WHEN variant = 'control' THEN 1 WHEN variant = 'delta_lift' THEN 3 ELSE 2 END)
