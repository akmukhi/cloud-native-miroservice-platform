-- Sample Queries and Usage Examples for Analytics
-- This script provides practical examples of how to use the analytics views and functions

-- =====================================================
-- USER ANALYTICS QUERIES
-- =====================================================

-- 1. Get top 10 most engaged users
SELECT 
    first_name,
    last_name,
    email,
    engagement_score,
    total_notifications,
    engagement_level
FROM top_engaged_users
LIMIT 10;

-- 2. User registration trends for the last 30 days
SELECT 
    registration_date,
    new_users,
    cumulative_users
FROM user_registration_trends
WHERE registration_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY registration_date DESC;

-- 3. User retention analysis by cohort
SELECT 
    cohort_month,
    cohort_size,
    retention_month_0,
    retention_month_1,
    retention_month_2,
    retention_month_3
FROM user_retention_cohorts
ORDER BY cohort_month DESC;

-- 4. User segmentation analysis
SELECT 
    user_segment,
    COUNT(*) AS user_count,
    ROUND((COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM users WHERE is_active = true)) * 100, 2) AS percentage
FROM user_segments
GROUP BY user_segment
ORDER BY user_count DESC;

-- 5. Geographic user distribution
SELECT 
    region,
    user_count,
    percentage
FROM geographic_user_distribution
ORDER BY user_count DESC;

-- =====================================================
-- NOTIFICATION ANALYTICS QUERIES
-- =====================================================

-- 6. Notification delivery performance by type
SELECT 
    notification_type,
    total_notifications,
    successful_deliveries,
    success_rate,
    avg_delivery_time_seconds
FROM notification_delivery_performance
ORDER BY success_rate DESC;

-- 7. Notification volume trends for the last 7 days
SELECT 
    notification_date,
    notification_type,
    notification_count,
    daily_success_rate
FROM notification_volume_trends
WHERE notification_date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY notification_date DESC, notification_type;

-- 8. Optimal notification timing analysis
SELECT 
    hour,
    day_name,
    notification_type,
    success_rate,
    timing_quality
FROM optimal_notification_timing
WHERE total_notifications >= 10
ORDER BY success_rate DESC;

-- 9. Notification error analysis
SELECT 
    notification_type,
    error_message,
    error_count,
    avg_retry_attempts
FROM notification_error_analysis
ORDER BY error_count DESC;

-- 10. Notification efficiency dashboard
SELECT 
    notification_type,
    total_notifications,
    success_rate,
    efficiency_score,
    efficiency_rating
FROM notification_efficiency_dashboard
ORDER BY efficiency_score DESC;

-- =====================================================
-- BUSINESS ANALYTICS QUERIES
-- =====================================================

-- 11. Brand performance analysis
SELECT 
    brand,
    total_releases,
    avg_price,
    total_notifications_sent,
    notification_success_rate
FROM brand_performance_analysis
ORDER BY total_notifications_sent DESC;

-- 12. Price range performance analysis
SELECT 
    price_range,
    total_releases,
    avg_price,
    total_notifications_sent,
    notification_success_rate
FROM price_range_performance
ORDER BY avg_price;

-- 13. Limited edition vs regular release performance
SELECT 
    release_type,
    total_releases,
    avg_price,
    total_notifications_sent,
    notification_success_rate
FROM limited_edition_performance;

-- 14. Monthly business metrics
SELECT 
    month,
    total_releases,
    limited_edition_releases,
    total_release_value,
    avg_release_price,
    total_notifications_sent,
    notification_success_rate
FROM monthly_business_metrics
ORDER BY month DESC;

-- 15. User acquisition and retention metrics
SELECT 
    month,
    new_users,
    active_users,
    month_1_retention_rate,
    month_2_retention_rate,
    notification_success_rate
FROM user_acquisition_retention_metrics
ORDER BY month DESC;

-- =====================================================
-- PREDICTIVE ANALYTICS QUERIES
-- =====================================================

-- 16. Predict success probability for a new watch release
SELECT 
    predict_watch_release_success(
        'Rolex',           -- brand
        15000.00,          -- price
        true,              -- is_limited_edition
        3,                 -- category_count
        5                  -- feature_count
    ) AS predicted_success_rate;

-- 17. Predict user engagement for specific users
SELECT 
    u.id,
    u.first_name,
    u.last_name,
    calculate_user_engagement_score(u.id) AS current_engagement,
    predict_user_engagement(u.id, 30) AS predicted_engagement_30_days,
    predict_user_engagement(u.id, 90) AS predicted_engagement_90_days
FROM users u
WHERE u.is_active = true
ORDER BY current_engagement DESC
LIMIT 10;

-- =====================================================
-- DATA WAREHOUSE QUERIES
-- =====================================================

-- 18. Daily notification facts from data warehouse
SELECT 
    date_key,
    month_name,
    day_name,
    notification_type,
    total_notifications,
    success_rate,
    avg_delivery_time_seconds
FROM daily_notification_facts
WHERE date_key >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY date_key DESC, notification_type;

-- 19. User engagement facts from data warehouse
SELECT 
    user_id,
    first_name,
    last_name,
    total_notifications,
    success_rate,
    user_segment,
    days_since_last_activity
FROM user_engagement_facts
WHERE total_notifications > 0
ORDER BY total_notifications DESC
LIMIT 20;

-- 20. Watch release performance facts from data warehouse
SELECT 
    watch_name,
    brand,
    price_tier,
    total_notifications_sent,
    notification_success_rate,
    days_since_release
FROM watch_release_performance_facts
WHERE days_since_release <= 30
ORDER BY total_notifications_sent DESC;

-- =====================================================
-- COMPLEX ANALYTICAL QUERIES
-- =====================================================

-- 21. User behavior correlation analysis
WITH user_behavior AS (
    SELECT 
        u.id,
        u.first_name,
        u.last_name,
        array_length(u.preferences, 1) AS preference_count,
        COUNT(n.id) AS notification_count,
        AVG(EXTRACT(EPOCH FROM (n.sent_at - n.created_at))) AS avg_response_time,
        COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications,
        COUNT(*) FILTER (WHERE n.status = 'FAILED') AS failed_notifications
    FROM users u
    LEFT JOIN notifications n ON u.id = n.user_id
    WHERE u.is_active = true
    GROUP BY u.id, u.first_name, u.last_name, u.preferences
)
SELECT 
    CASE 
        WHEN preference_count >= 5 THEN 'High Preferences'
        WHEN preference_count >= 3 THEN 'Medium Preferences'
        ELSE 'Low Preferences'
    END AS preference_level,
    COUNT(*) AS user_count,
    AVG(notification_count) AS avg_notifications,
    AVG(avg_response_time) AS avg_response_time_seconds,
    ROUND(
        (SUM(successful_notifications)::DECIMAL / SUM(successful_notifications + failed_notifications)) * 100, 2
    ) AS overall_success_rate
FROM user_behavior
GROUP BY preference_level
ORDER BY avg_notifications DESC;

-- 22. Time-based notification performance analysis
WITH hourly_performance AS (
    SELECT 
        EXTRACT(HOUR FROM created_at) AS hour,
        notification_type,
        COUNT(*) AS total_notifications,
        COUNT(*) FILTER (WHERE status = 'SENT') AS successful_notifications,
        AVG(EXTRACT(EPOCH FROM (sent_at - created_at))) AS avg_delivery_time
    FROM notifications
    WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY EXTRACT(HOUR FROM created_at), notification_type
)
SELECT 
    hour,
    notification_type,
    total_notifications,
    ROUND((successful_notifications::DECIMAL / total_notifications) * 100, 2) AS success_rate,
    avg_delivery_time,
    CASE 
        WHEN hour BETWEEN 9 AND 17 THEN 'Business Hours'
        WHEN hour BETWEEN 18 AND 22 THEN 'Evening'
        WHEN hour BETWEEN 23 AND 8 THEN 'Night'
    END AS time_period
FROM hourly_performance
ORDER BY hour, notification_type;

-- 23. Brand and category correlation analysis
WITH brand_category_performance AS (
    SELECT 
        wr.brand,
        c.category,
        COUNT(n.id) AS total_notifications,
        COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications,
        AVG(wr.price) AS avg_price
    FROM watch_releases wr
    CROSS JOIN LATERAL unnest(wr.categories) AS c(category)
    LEFT JOIN notifications n ON wr.id = n.watch_release_id
    GROUP BY wr.brand, c.category
)
SELECT 
    brand,
    category,
    total_notifications,
    ROUND((successful_notifications::DECIMAL / total_notifications) * 100, 2) AS success_rate,
    avg_price,
    CASE 
        WHEN avg_price < 1000 THEN 'Budget'
        WHEN avg_price < 5000 THEN 'Mid-Range'
        WHEN avg_price < 10000 THEN 'Luxury'
        ELSE 'High-End'
    END AS price_category
FROM brand_category_performance
WHERE total_notifications >= 5
ORDER BY success_rate DESC;

-- 24. User lifetime value analysis with engagement prediction
WITH user_ltv_prediction AS (
    SELECT 
        u.id,
        u.first_name,
        u.last_name,
        u.email,
        COUNT(n.id) AS total_notifications,
        COUNT(DISTINCT wr.id) AS unique_watches_interested,
        AVG(wr.price) AS avg_watch_price_interested,
        array_length(u.preferences, 1) AS preference_count,
        calculate_user_engagement_score(u.id) AS current_engagement,
        predict_user_engagement(u.id, 90) AS predicted_engagement_90_days
    FROM users u
    LEFT JOIN notifications n ON u.id = n.user_id AND n.status = 'SENT'
    LEFT JOIN watch_releases wr ON n.watch_release_id = wr.id
    WHERE u.is_active = true
    GROUP BY u.id, u.first_name, u.last_name, u.email, u.preferences
)
SELECT 
    id,
    first_name,
    last_name,
    email,
    total_notifications,
    unique_watches_interested,
    avg_watch_price_interested,
    preference_count,
    current_engagement,
    predicted_engagement_90_days,
    (total_notifications * 0.1 * avg_watch_price_interested) AS estimated_current_ltv,
    (predicted_engagement_90_days * 0.1 * avg_watch_price_interested) AS estimated_future_ltv,
    CASE 
        WHEN predicted_engagement_90_days > current_engagement * 1.2 THEN 'Growing'
        WHEN predicted_engagement_90_days > current_engagement * 0.8 THEN 'Stable'
        ELSE 'Declining'
    END AS engagement_trend
FROM user_ltv_prediction
ORDER BY estimated_future_ltv DESC;

-- 25. Comprehensive business dashboard query
WITH business_summary AS (
    SELECT 
        DATE_TRUNC('month', CURRENT_DATE) AS current_month,
        COUNT(DISTINCT u.id) AS total_users,
        COUNT(DISTINCT wr.id) AS total_releases,
        COUNT(n.id) AS total_notifications,
        COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications,
        SUM(wr.price) AS total_release_value
    FROM users u
    CROSS JOIN watch_releases wr
    LEFT JOIN notifications n ON u.id = n.user_id AND wr.id = n.watch_release_id
    WHERE u.is_active = true
    AND wr.release_date >= DATE_TRUNC('month', CURRENT_DATE)
    AND n.created_at >= DATE_TRUNC('month', CURRENT_DATE)
),
monthly_comparison AS (
    SELECT 
        DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month') AS previous_month,
        COUNT(DISTINCT u.id) AS previous_total_users,
        COUNT(DISTINCT wr.id) AS previous_total_releases,
        COUNT(n.id) AS previous_total_notifications,
        COUNT(*) FILTER (WHERE n.status = 'SENT') AS previous_successful_notifications
    FROM users u
    CROSS JOIN watch_releases wr
    LEFT JOIN notifications n ON u.id = n.user_id AND wr.id = n.watch_release_id
    WHERE u.is_active = true
    AND wr.release_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
    AND wr.release_date < DATE_TRUNC('month', CURRENT_DATE)
    AND n.created_at >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
    AND n.created_at < DATE_TRUNC('month', CURRENT_DATE)
)
SELECT 
    bs.current_month,
    bs.total_users,
    bs.total_releases,
    bs.total_notifications,
    bs.successful_notifications,
    bs.total_release_value,
    ROUND((bs.successful_notifications::DECIMAL / bs.total_notifications) * 100, 2) AS success_rate,
    ROUND((bs.total_users - mc.previous_total_users)::DECIMAL / mc.previous_total_users * 100, 2) AS user_growth_rate,
    ROUND((bs.total_notifications - mc.previous_total_notifications)::DECIMAL / mc.previous_total_notifications * 100, 2) AS notification_growth_rate
FROM business_summary bs
CROSS JOIN monthly_comparison mc;

-- =====================================================
-- REFRESH AND MAINTENANCE QUERIES
-- =====================================================

-- 26. Refresh analytics views
SELECT refresh_analytics_views();

-- 27. Populate fact tables
SELECT populate_fact_tables();

-- 28. Check analytics refresh log
SELECT 
    refresh_time,
    status,
    message
FROM analytics_refresh_log
ORDER BY refresh_time DESC
LIMIT 10;

-- 29. Check materialized view sizes
SELECT 
    schemaname,
    matviewname,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||matviewname)) AS size
FROM pg_matviews
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||matviewname) DESC;

-- 30. Performance monitoring query
SELECT 
    'User Analytics' AS category,
    COUNT(*) AS view_count
FROM user_registration_trends
UNION ALL
SELECT 
    'Notification Analytics' AS category,
    COUNT(*) AS view_count
FROM notification_delivery_performance
UNION ALL
SELECT 
    'Business Analytics' AS category,
    COUNT(*) AS view_count
FROM brand_performance_analysis;
