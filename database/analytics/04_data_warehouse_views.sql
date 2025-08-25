-- Data Warehouse Views and Materialized Views for Analytics
-- This script provides optimized data warehouse views for the Watch Notification Service

-- =====================================================
-- MATERIALIZED VIEWS FOR PERFORMANCE
-- =====================================================

-- 1. Daily User Activity Summary (Materialized View)
CREATE MATERIALIZED VIEW daily_user_activity_summary AS
SELECT 
    DATE_TRUNC('day', u.created_at) AS activity_date,
    COUNT(DISTINCT u.id) AS new_users,
    COUNT(DISTINCT n.user_id) AS active_users,
    COUNT(n.id) AS total_notifications,
    COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications,
    COUNT(*) FILTER (WHERE n.status = 'FAILED') AS failed_notifications,
    ROUND(
        (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS success_rate,
    AVG(EXTRACT(EPOCH FROM (n.sent_at - n.created_at))) AS avg_delivery_time_seconds
FROM users u
LEFT JOIN notifications n ON u.id = n.user_id 
    AND DATE_TRUNC('day', n.created_at) = DATE_TRUNC('day', u.created_at)
WHERE u.created_at >= NOW() - INTERVAL '90 days'
GROUP BY DATE_TRUNC('day', u.created_at)
ORDER BY activity_date DESC;

-- Create index for faster refresh
CREATE INDEX idx_daily_user_activity_date ON daily_user_activity_summary(activity_date);

-- 2. Monthly Business Metrics (Materialized View)
CREATE MATERIALIZED VIEW monthly_business_metrics_summary AS
SELECT 
    DATE_TRUNC('month', wr.release_date) AS month,
    COUNT(wr.id) AS total_releases,
    COUNT(*) FILTER (WHERE wr.is_limited_edition = true) AS limited_edition_releases,
    SUM(wr.price) AS total_release_value,
    AVG(wr.price) AS avg_release_price,
    COUNT(n.id) AS total_notifications_sent,
    COUNT(DISTINCT n.user_id) AS unique_users_notified,
    COUNT(DISTINCT wr.brand) AS unique_brands,
    ROUND(
        (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS notification_success_rate,
    ROUND((COUNT(n.id)::DECIMAL / COUNT(wr.id)), 2) AS avg_notifications_per_release
FROM watch_releases wr
LEFT JOIN notifications n ON wr.id = n.watch_release_id
WHERE wr.release_date >= NOW() - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', wr.release_date)
ORDER BY month DESC;

-- Create index for faster refresh
CREATE INDEX idx_monthly_business_metrics_month ON monthly_business_metrics_summary(month);

-- 3. User Engagement Summary (Materialized View)
CREATE MATERIALIZED VIEW user_engagement_summary AS
SELECT 
    u.id,
    u.first_name,
    u.last_name,
    u.email,
    u.created_at,
    array_length(u.preferences, 1) AS preference_count,
    COUNT(n.id) AS total_notifications,
    COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications,
    MAX(n.created_at) AS last_activity,
    EXTRACT(DAY FROM NOW() - u.created_at) AS days_since_registration,
    EXTRACT(DAY FROM NOW() - MAX(n.created_at)) AS days_since_last_activity,
    ROUND(
        (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS success_rate,
    AVG(EXTRACT(EPOCH FROM (n.sent_at - n.created_at))) AS avg_response_time_seconds
FROM users u
LEFT JOIN notifications n ON u.id = n.user_id
WHERE u.is_active = true
GROUP BY u.id, u.first_name, u.last_name, u.email, u.created_at, u.preferences
ORDER BY total_notifications DESC;

-- Create indexes for faster queries
CREATE INDEX idx_user_engagement_id ON user_engagement_summary(id);
CREATE INDEX idx_user_engagement_last_activity ON user_engagement_summary(last_activity);
CREATE INDEX idx_user_engagement_total_notifications ON user_engagement_summary(total_notifications);

-- 4. Watch Release Performance Summary (Materialized View)
CREATE MATERIALIZED VIEW watch_release_performance_summary AS
SELECT 
    wr.id,
    wr.watch_name,
    wr.brand,
    wr.model_number,
    wr.price,
    wr.currency,
    wr.is_limited_edition,
    wr.limited_quantity,
    wr.release_date,
    wr.is_notified,
    wr.notification_sent_at,
    COUNT(n.id) AS total_notifications_sent,
    COUNT(DISTINCT n.user_id) AS unique_users_notified,
    COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications,
    COUNT(*) FILTER (WHERE n.status = 'FAILED') AS failed_notifications,
    ROUND(
        (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS notification_success_rate,
    AVG(EXTRACT(EPOCH FROM (n.sent_at - n.created_at))) AS avg_delivery_time_seconds,
    EXTRACT(DAY FROM NOW() - wr.release_date) AS days_since_release
FROM watch_releases wr
LEFT JOIN notifications n ON wr.id = n.watch_release_id
GROUP BY wr.id, wr.watch_name, wr.brand, wr.model_number, wr.price, wr.currency, 
         wr.is_limited_edition, wr.limited_quantity, wr.release_date, wr.is_notified, wr.notification_sent_at
ORDER BY total_notifications_sent DESC;

-- Create indexes for faster queries
CREATE INDEX idx_watch_release_performance_id ON watch_release_performance_summary(id);
CREATE INDEX idx_watch_release_performance_brand ON watch_release_performance_summary(brand);
CREATE INDEX idx_watch_release_performance_release_date ON watch_release_performance_summary(release_date);

-- =====================================================
-- DIMENSION TABLES FOR DATA WAREHOUSE
-- =====================================================

-- 5. Date Dimension Table
CREATE TABLE IF NOT EXISTS dim_date (
    date_key DATE PRIMARY KEY,
    year INTEGER,
    quarter INTEGER,
    month INTEGER,
    month_name TEXT,
    week_of_year INTEGER,
    day_of_year INTEGER,
    day_of_month INTEGER,
    day_of_week INTEGER,
    day_name TEXT,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN
);

-- Populate date dimension for the last 2 years
INSERT INTO dim_date
SELECT 
    date_series::DATE AS date_key,
    EXTRACT(YEAR FROM date_series) AS year,
    EXTRACT(QUARTER FROM date_series) AS quarter,
    EXTRACT(MONTH FROM date_series) AS month,
    TO_CHAR(date_series, 'Month') AS month_name,
    EXTRACT(WEEK FROM date_series) AS week_of_year,
    EXTRACT(DOY FROM date_series) AS day_of_year,
    EXTRACT(DAY FROM date_series) AS day_of_month,
    EXTRACT(DOW FROM date_series) AS day_of_week,
    TO_CHAR(date_series, 'Day') AS day_name,
    EXTRACT(DOW FROM date_series) IN (0, 6) AS is_weekend,
    FALSE AS is_holiday
FROM generate_series(
    CURRENT_DATE - INTERVAL '2 years',
    CURRENT_DATE + INTERVAL '1 year',
    INTERVAL '1 day'
) AS date_series
ON CONFLICT (date_key) DO NOTHING;

-- 6. User Dimension Table
CREATE TABLE IF NOT EXISTS dim_user (
    user_key BIGINT PRIMARY KEY,
    user_id BIGINT,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    phone_number TEXT,
    created_date DATE,
    is_active BOOLEAN,
    email_notifications_enabled BOOLEAN,
    sms_notifications_enabled BOOLEAN,
    push_notifications_enabled BOOLEAN,
    preference_count INTEGER,
    last_updated TIMESTAMP DEFAULT NOW()
);

-- 7. Watch Release Dimension Table
CREATE TABLE IF NOT EXISTS dim_watch_release (
    watch_release_key BIGINT PRIMARY KEY,
    watch_release_id BIGINT,
    watch_name TEXT,
    brand TEXT,
    model_number TEXT,
    price DECIMAL,
    currency TEXT,
    is_limited_edition BOOLEAN,
    limited_quantity INTEGER,
    release_date DATE,
    is_notified BOOLEAN,
    notification_sent_date DATE,
    category_count INTEGER,
    feature_count INTEGER,
    last_updated TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- FACT TABLES FOR DATA WAREHOUSE
-- =====================================================

-- 8. Notification Fact Table
CREATE TABLE IF NOT EXISTS fact_notifications (
    notification_key BIGSERIAL PRIMARY KEY,
    notification_id BIGINT,
    user_key BIGINT REFERENCES dim_user(user_key),
    watch_release_key BIGINT REFERENCES dim_watch_release(watch_release_key),
    date_key DATE REFERENCES dim_date(date_key),
    notification_type TEXT,
    status TEXT,
    retry_count INTEGER,
    created_timestamp TIMESTAMP,
    sent_timestamp TIMESTAMP,
    delivery_time_seconds INTEGER,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 9. User Activity Fact Table
CREATE TABLE IF NOT EXISTS fact_user_activity (
    activity_key BIGSERIAL PRIMARY KEY,
    user_key BIGINT REFERENCES dim_user(user_key),
    date_key DATE REFERENCES dim_date(date_key),
    activity_type TEXT,
    activity_count INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================
-- DATA WAREHOUSE VIEWS
-- =====================================================

-- 10. Daily Notification Fact View
CREATE OR REPLACE VIEW daily_notification_facts AS
SELECT 
    d.date_key,
    d.year,
    d.month,
    d.month_name,
    d.day_name,
    d.is_weekend,
    n.notification_type,
    COUNT(*) AS total_notifications,
    COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications,
    COUNT(*) FILTER (WHERE n.status = 'FAILED') AS failed_notifications,
    COUNT(*) FILTER (WHERE n.status = 'PENDING') AS pending_notifications,
    COUNT(DISTINCT n.user_key) AS unique_users,
    COUNT(DISTINCT n.watch_release_key) AS unique_watches,
    ROUND(
        (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS success_rate,
    AVG(n.delivery_time_seconds) AS avg_delivery_time_seconds,
    AVG(n.retry_count) AS avg_retry_count
FROM fact_notifications n
JOIN dim_date d ON n.date_key = d.date_key
GROUP BY d.date_key, d.year, d.month, d.month_name, d.day_name, d.is_weekend, n.notification_type
ORDER BY d.date_key DESC, n.notification_type;

-- 11. User Engagement Fact View
CREATE OR REPLACE VIEW user_engagement_facts AS
SELECT 
    u.user_key,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.created_date,
    u.preference_count,
    COUNT(n.notification_key) AS total_notifications,
    COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications,
    MAX(n.date_key) AS last_activity_date,
    EXTRACT(DAY FROM CURRENT_DATE - u.created_date) AS days_since_registration,
    EXTRACT(DAY FROM CURRENT_DATE - MAX(n.date_key)) AS days_since_last_activity,
    ROUND(
        (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS success_rate,
    AVG(n.delivery_time_seconds) AS avg_response_time_seconds,
    CASE 
        WHEN COUNT(n.notification_key) >= 20 THEN 'Power User'
        WHEN COUNT(n.notification_key) >= 10 THEN 'Active User'
        WHEN COUNT(n.notification_key) >= 5 THEN 'Regular User'
        WHEN COUNT(n.notification_key) > 0 THEN 'Occasional User'
        ELSE 'Inactive User'
    END AS user_segment
FROM dim_user u
LEFT JOIN fact_notifications n ON u.user_key = n.user_key
GROUP BY u.user_key, u.user_id, u.first_name, u.last_name, u.email, u.created_date, u.preference_count
ORDER BY total_notifications DESC;

-- 12. Watch Release Performance Fact View
CREATE OR REPLACE VIEW watch_release_performance_facts AS
SELECT 
    wr.watch_release_key,
    wr.watch_release_id,
    wr.watch_name,
    wr.brand,
    wr.model_number,
    wr.price,
    wr.currency,
    wr.is_limited_edition,
    wr.limited_quantity,
    wr.release_date,
    wr.category_count,
    wr.feature_count,
    COUNT(n.notification_key) AS total_notifications_sent,
    COUNT(DISTINCT n.user_key) AS unique_users_notified,
    COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications,
    COUNT(*) FILTER (WHERE n.status = 'FAILED') AS failed_notifications,
    ROUND(
        (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS notification_success_rate,
    AVG(n.delivery_time_seconds) AS avg_delivery_time_seconds,
    EXTRACT(DAY FROM CURRENT_DATE - wr.release_date) AS days_since_release,
    CASE 
        WHEN wr.price < 1000 THEN 'Budget'
        WHEN wr.price < 5000 THEN 'Mid-Range'
        WHEN wr.price < 10000 THEN 'Luxury'
        WHEN wr.price < 50000 THEN 'High-End'
        ELSE 'Ultra-Luxury'
    END AS price_tier
FROM dim_watch_release wr
LEFT JOIN fact_notifications n ON wr.watch_release_key = n.watch_release_key
GROUP BY wr.watch_release_key, wr.watch_release_id, wr.watch_name, wr.brand, wr.model_number, 
         wr.price, wr.currency, wr.is_limited_edition, wr.limited_quantity, wr.release_date, 
         wr.category_count, wr.feature_count
ORDER BY total_notifications_sent DESC;

-- =====================================================
-- REFRESH FUNCTIONS
-- =====================================================

-- 13. Function to refresh materialized views
CREATE OR REPLACE FUNCTION refresh_analytics_views()
RETURNS VOID AS $$
BEGIN
    -- Refresh materialized views
    REFRESH MATERIALIZED VIEW daily_user_activity_summary;
    REFRESH MATERIALIZED VIEW monthly_business_metrics_summary;
    REFRESH MATERIALIZED VIEW user_engagement_summary;
    REFRESH MATERIALIZED VIEW watch_release_performance_summary;
    
    -- Log refresh
    RAISE NOTICE 'Analytics views refreshed at %', NOW();
END;
$$ LANGUAGE plpgsql;

-- 14. Function to populate fact tables
CREATE OR REPLACE FUNCTION populate_fact_tables()
RETURNS VOID AS $$
BEGIN
    -- Populate user dimension
    INSERT INTO dim_user (
        user_key, user_id, first_name, last_name, email, phone_number, 
        created_date, is_active, email_notifications_enabled, 
        sms_notifications_enabled, push_notifications_enabled, preference_count
    )
    SELECT 
        id, id, first_name, last_name, email, phone_number,
        DATE(created_at), is_active, email_notifications_enabled,
        sms_notifications_enabled, push_notifications_enabled, array_length(preferences, 1)
    FROM users
    ON CONFLICT (user_key) DO UPDATE SET
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        email = EXCLUDED.email,
        phone_number = EXCLUDED.phone_number,
        is_active = EXCLUDED.is_active,
        email_notifications_enabled = EXCLUDED.email_notifications_enabled,
        sms_notifications_enabled = EXCLUDED.sms_notifications_enabled,
        push_notifications_enabled = EXCLUDED.push_notifications_enabled,
        preference_count = EXCLUDED.preference_count,
        last_updated = NOW();
    
    -- Populate watch release dimension
    INSERT INTO dim_watch_release (
        watch_release_key, watch_release_id, watch_name, brand, model_number,
        price, currency, is_limited_edition, limited_quantity, release_date,
        is_notified, notification_sent_date, category_count, feature_count
    )
    SELECT 
        id, id, watch_name, brand, model_number,
        price, currency, is_limited_edition, limited_quantity, DATE(release_date),
        is_notified, DATE(notification_sent_at), array_length(categories, 1), array_length(features, 1)
    FROM watch_releases
    ON CONFLICT (watch_release_key) DO UPDATE SET
        watch_name = EXCLUDED.watch_name,
        brand = EXCLUDED.brand,
        model_number = EXCLUDED.model_number,
        price = EXCLUDED.price,
        currency = EXCLUDED.currency,
        is_limited_edition = EXCLUDED.is_limited_edition,
        limited_quantity = EXCLUDED.limited_quantity,
        release_date = EXCLUDED.release_date,
        is_notified = EXCLUDED.is_notified,
        notification_sent_date = EXCLUDED.notification_sent_date,
        category_count = EXCLUDED.category_count,
        feature_count = EXCLUDED.feature_count,
        last_updated = NOW();
    
    -- Populate notification fact table
    INSERT INTO fact_notifications (
        notification_id, user_key, watch_release_key, date_key, notification_type,
        status, retry_count, created_timestamp, sent_timestamp, delivery_time_seconds, error_message
    )
    SELECT 
        n.id, n.user_id, n.watch_release_id, DATE(n.created_at), n.notification_type,
        n.status, n.retry_count, n.created_at, n.sent_at,
        EXTRACT(EPOCH FROM (n.sent_at - n.created_at))::INTEGER, n.error_message
    FROM notifications n
    WHERE n.id NOT IN (SELECT notification_id FROM fact_notifications WHERE notification_id IS NOT NULL);
    
    RAISE NOTICE 'Fact tables populated at %', NOW();
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SCHEDULED REFRESH
-- =====================================================

-- 15. Create a function to be called by cron job
CREATE OR REPLACE FUNCTION scheduled_analytics_refresh()
RETURNS VOID AS $$
BEGIN
    -- Populate fact tables first
    PERFORM populate_fact_tables();
    
    -- Then refresh materialized views
    PERFORM refresh_analytics_views();
    
    -- Log the refresh
    INSERT INTO analytics_refresh_log (refresh_time, status, message)
    VALUES (NOW(), 'SUCCESS', 'Analytics refresh completed successfully');
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO analytics_refresh_log (refresh_time, status, message)
        VALUES (NOW(), 'ERROR', SQLERRM);
        RAISE;
END;
$$ LANGUAGE plpgsql;

-- 16. Create refresh log table
CREATE TABLE IF NOT EXISTS analytics_refresh_log (
    id BIGSERIAL PRIMARY KEY,
    refresh_time TIMESTAMP NOT NULL,
    status TEXT NOT NULL,
    message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create index for log queries
CREATE INDEX idx_analytics_refresh_log_time ON analytics_refresh_log(refresh_time);
CREATE INDEX idx_analytics_refresh_log_status ON analytics_refresh_log(status);
