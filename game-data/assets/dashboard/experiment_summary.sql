/* @bruin
name: dashboard.experiment_summary
type: bq.sql
materialization:
    type: table

depends:
  - python_analytics.player_features
@bruin */

SELECT
    experiment_id,
    variant,
    COUNT(player_id) AS total_players,
    
    -- Engagement Metrics
    ROUND(AVG(days_active), 2) AS avg_days_active,
    ROUND(AVG(total_sessions), 2) AS avg_sessions_per_player,
    
    -- Monetization Metrics
    COUNTIF(has_purchase) AS paying_players,
    ROUND(COUNTIF(has_purchase) / COUNT(DISTINCT player_id), 4) AS conversion_rate,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    ROUND(SUM(total_revenue) / COUNT(DISTINCT player_id), 2) AS arpu, -- Average Revenue Per User
    ROUND(SAFE_DIVIDE(SUM(total_revenue), COUNTIF(has_purchase)), 2) AS arppu -- Average Revenue Per Paying User

FROM python_analytics.player_features
GROUP BY 1, 2
ORDER BY 1, 2
