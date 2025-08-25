-- Business Analytics and Watch Release Performance Analysis
-- This script provides comprehensive business analytics for the Watch Notification Service

-- =====================================================
-- WATCH RELEASE ANALYTICS
-- =====================================================

-- 1. Watch Release Performance Overview
CREATE OR REPLACE VIEW watch_release_performance AS
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

-- 2. Brand Performance Analysis
CREATE OR REPLACE VIEW brand_performance_analysis AS
SELECT 
    wr.brand,
    COUNT(wr.id) AS total_releases,
    COUNT(*) FILTER (WHERE wr.is_limited_edition = true) AS limited_edition_releases,
    AVG(wr.price) AS avg_price,
    MIN(wr.price) AS min_price,
    MAX(wr.price) AS max_price,
    COUNT(n.id) AS total_notifications_sent,
    COUNT(DISTINCT n.user_id) AS unique_users_notified,
    ROUND(
        (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS notification_success_rate,
    AVG(EXTRACT(EPOCH FROM (n.sent_at - n.created_at))) AS avg_delivery_time_seconds
FROM watch_releases wr
LEFT JOIN notifications n ON wr.id = n.watch_release_id
GROUP BY wr.brand
ORDER BY total_notifications_sent DESC;

-- 3. Price Range Performance Analysis
CREATE OR REPLACE VIEW price_range_performance AS
SELECT 
    CASE 
        WHEN wr.price < 1000 THEN 'Budget (< $1,000)'
        WHEN wr.price < 5000 THEN 'Mid-Range ($1,000 - $5,000)'
        WHEN wr.price < 10000 THEN 'Luxury ($5,000 - $10,000)'
        WHEN wr.price < 50000 THEN 'High-End ($10,000 - $50,000)'
        ELSE 'Ultra-Luxury (> $50,000)'
    END AS price_range,
    COUNT(wr.id) AS total_releases,
    COUNT(*) FILTER (WHERE wr.is_limited_edition = true) AS limited_edition_count,
    AVG(wr.price) AS avg_price,
    COUNT(n.id) AS total_notifications_sent,
    COUNT(DISTINCT n.user_id) AS unique_users_notified,
    ROUND(
        (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS notification_success_rate
FROM watch_releases wr
LEFT JOIN notifications n ON wr.id = n.watch_release_id
GROUP BY price_range
ORDER BY avg_price;

-- 4. Limited Edition Performance Analysis
CREATE OR REPLACE VIEW limited_edition_performance AS
SELECT 
    'Limited Edition' AS release_type,
    COUNT(wr.id) AS total_releases,
    AVG(wr.limited_quantity) AS avg_limited_quantity,
    AVG(wr.price) AS avg_price,
    COUNT(n.id) AS total_notifications_sent,
    COUNT(DISTINCT n.user_id) AS unique_users_notified,
    ROUND(
        (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS notification_success_rate,
    AVG(EXTRACT(EPOCH FROM (n.sent_at - n.created_at))) AS avg_delivery_time_seconds
FROM watch_releases wr
LEFT JOIN notifications n ON wr.id = n.watch_release_id
WHERE wr.is_limited_edition = true

UNION ALL

SELECT 
    'Regular Release' AS release_type,
    COUNT(wr.id) AS total_releases,
    NULL AS avg_limited_quantity,
    AVG(wr.price) AS avg_price,
    COUNT(n.id) AS total_notifications_sent,
    COUNT(DISTINCT n.user_id) AS unique_users_notified,
    ROUND(
        (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS notification_success_rate,
    AVG(EXTRACT(EPOCH FROM (n.sent_at - n.created_at))) AS avg_delivery_time_seconds
FROM watch_releases wr
LEFT JOIN notifications n ON wr.id = n.watch_release_id
WHERE wr.is_limited_edition = false;

-- 5. Release Timing Analysis
CREATE OR REPLACE VIEW release_timing_analysis AS
SELECT 
    EXTRACT(MONTH FROM wr.release_date) AS release_month,
    TO_CHAR(wr.release_date, 'Month') AS month_name,
    COUNT(wr.id) AS total_releases,
    COUNT(*) FILTER (WHERE wr.is_limited_edition = true) AS limited_edition_releases,
    AVG(wr.price) AS avg_price,
    COUNT(n.id) AS total_notifications_sent,
    COUNT(DISTINCT n.user_id) AS unique_users_notified,
    ROUND(
        (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS notification_success_rate
FROM watch_releases wr
LEFT JOIN notifications n ON wr.id = n.watch_release_id
WHERE wr.release_date >= NOW() - INTERVAL '1 year'
GROUP BY EXTRACT(MONTH FROM wr.release_date), TO_CHAR(wr.release_date, 'Month')
ORDER BY release_month;

-- =====================================================
-- CATEGORY AND FEATURE ANALYTICS
-- =====================================================

-- 6. Category Performance Analysis
CREATE OR REPLACE VIEW category_performance_analysis AS
WITH category_metrics AS (
    SELECT 
        c.category,
        COUNT(wr.id) AS total_releases,
        AVG(wr.price) AS avg_price,
        COUNT(*) FILTER (WHERE wr.is_limited_edition = true) AS limited_edition_count,
        COUNT(n.id) AS total_notifications_sent,
        COUNT(DISTINCT n.user_id) AS unique_users_notified,
        ROUND(
            (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
        ) AS notification_success_rate
    FROM watch_releases wr
    CROSS JOIN LATERAL unnest(wr.categories) AS c(category)
    LEFT JOIN notifications n ON wr.id = n.watch_release_id
    GROUP BY c.category
)
SELECT 
    category,
    total_releases,
    avg_price,
    limited_edition_count,
    total_notifications_sent,
    unique_users_notified,
    notification_success_rate,
    ROUND((total_notifications_sent::DECIMAL / total_releases), 2) AS avg_notifications_per_release
FROM category_metrics
ORDER BY total_notifications_sent DESC;

-- 7. Feature Performance Analysis
CREATE OR REPLACE VIEW feature_performance_analysis AS
WITH feature_metrics AS (
    SELECT 
        f.feature,
        COUNT(wr.id) AS total_releases,
        AVG(wr.price) AS avg_price,
        COUNT(*) FILTER (WHERE wr.is_limited_edition = true) AS limited_edition_count,
        COUNT(n.id) AS total_notifications_sent,
        COUNT(DISTINCT n.user_id) AS unique_users_notified,
        ROUND(
            (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
        ) AS notification_success_rate
    FROM watch_releases wr
    CROSS JOIN LATERAL unnest(wr.features) AS f(feature)
    LEFT JOIN notifications n ON wr.id = n.watch_release_id
    GROUP BY f.feature
)
SELECT 
    feature,
    total_releases,
    avg_price,
    limited_edition_count,
    total_notifications_sent,
    unique_users_notified,
    notification_success_rate,
    ROUND((total_notifications_sent::DECIMAL / total_releases), 2) AS avg_notifications_per_release
FROM feature_metrics
ORDER BY total_notifications_sent DESC;

-- =====================================================
-- USER PREFERENCE AND INTEREST ANALYTICS
-- =====================================================

-- 8. User Interest by Category
CREATE OR REPLACE VIEW user_interest_by_category AS
WITH user_category_interest AS (
    SELECT 
        u.id,
        u.first_name,
        u.last_name,
        c.category,
        COUNT(n.id) AS notifications_received,
        COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications
    FROM users u
    CROSS JOIN LATERAL unnest(u.preferences) AS c(category)
    LEFT JOIN notifications n ON u.id = n.user_id
    LEFT JOIN watch_releases wr ON n.watch_release_id = wr.id
    LEFT JOIN LATERAL unnest(wr.categories) AS wc(category) ON c.category = wc.category
    WHERE u.is_active = true
    GROUP BY u.id, u.first_name, u.last_name, c.category
)
SELECT 
    category,
    COUNT(DISTINCT id) AS interested_users,
    SUM(notifications_received) AS total_notifications,
    SUM(successful_notifications) AS successful_notifications,
    ROUND(
        (SUM(successful_notifications)::DECIMAL / SUM(notifications_received)) * 100, 2
    ) AS success_rate
FROM user_category_interest
GROUP BY category
ORDER BY interested_users DESC;

-- 9. User Interest by Brand
CREATE OR REPLACE VIEW user_interest_by_brand AS
WITH user_brand_interest AS (
    SELECT 
        u.id,
        u.first_name,
        u.last_name,
        wr.brand,
        COUNT(n.id) AS notifications_received,
        COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications
    FROM users u
    LEFT JOIN notifications n ON u.id = n.user_id
    LEFT JOIN watch_releases wr ON n.watch_release_id = wr.id
    WHERE u.is_active = true
    GROUP BY u.id, u.first_name, u.last_name, wr.brand
)
SELECT 
    brand,
    COUNT(DISTINCT id) AS interested_users,
    SUM(notifications_received) AS total_notifications,
    SUM(successful_notifications) AS successful_notifications,
    ROUND(
        (SUM(successful_notifications)::DECIMAL / SUM(notifications_received)) * 100, 2
    ) AS success_rate
FROM user_brand_interest
GROUP BY brand
ORDER BY interested_users DESC;

-- =====================================================
-- BUSINESS METRICS AND KPIs
-- =====================================================

-- 10. Monthly Business Metrics Dashboard
CREATE OR REPLACE VIEW monthly_business_metrics AS
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

-- 11. User Acquisition and Retention Metrics
CREATE OR REPLACE VIEW user_acquisition_retention_metrics AS
WITH monthly_user_activity AS (
    SELECT 
        DATE_TRUNC('month', u.created_at) AS month,
        COUNT(u.id) AS new_users,
        COUNT(DISTINCT n.user_id) AS active_users,
        COUNT(n.id) AS total_notifications,
        COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications
    FROM users u
    LEFT JOIN notifications n ON u.id = n.user_id 
        AND DATE_TRUNC('month', n.created_at) = DATE_TRUNC('month', u.created_at)
    WHERE u.created_at >= NOW() - INTERVAL '12 months'
    GROUP BY DATE_TRUNC('month', u.created_at)
),
user_retention AS (
    SELECT 
        DATE_TRUNC('month', u.created_at) AS cohort_month,
        COUNT(u.id) AS cohort_size,
        COUNT(DISTINCT CASE WHEN n.created_at >= DATE_TRUNC('month', u.created_at) + INTERVAL '1 month' 
                           AND n.created_at < DATE_TRUNC('month', u.created_at) + INTERVAL '2 months' 
                           THEN n.user_id END) AS month_1_retained,
        COUNT(DISTINCT CASE WHEN n.created_at >= DATE_TRUNC('month', u.created_at) + INTERVAL '2 months' 
                           AND n.created_at < DATE_TRUNC('month', u.created_at) + INTERVAL '3 months' 
                           THEN n.user_id END) AS month_2_retained
    FROM users u
    LEFT JOIN notifications n ON u.id = n.user_id
    WHERE u.created_at >= NOW() - INTERVAL '12 months'
    GROUP BY DATE_TRUNC('month', u.created_at)
)
SELECT 
    m.month,
    m.new_users,
    m.active_users,
    m.total_notifications,
    m.successful_notifications,
    r.cohort_size,
    r.month_1_retained,
    r.month_2_retained,
    ROUND((r.month_1_retained::DECIMAL / r.cohort_size) * 100, 2) AS month_1_retention_rate,
    ROUND((r.month_2_retained::DECIMAL / r.cohort_size) * 100, 2) AS month_2_retention_rate,
    ROUND(
        (m.successful_notifications::DECIMAL / m.total_notifications) * 100, 2
    ) AS notification_success_rate
FROM monthly_user_activity m
LEFT JOIN user_retention r ON m.month = r.cohort_month
ORDER BY m.month DESC;

-- 12. Revenue Potential Analysis
CREATE OR REPLACE VIEW revenue_potential_analysis AS
WITH user_value_metrics AS (
    SELECT 
        u.id,
        u.first_name,
        u.last_name,
        u.email,
        COUNT(n.id) AS total_notifications,
        COUNT(DISTINCT wr.id) AS unique_watches_interested,
        AVG(wr.price) AS avg_watch_price_interested,
        SUM(wr.price) AS total_watch_value_interested,
        array_length(u.preferences, 1) AS preference_count
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
    total_watch_value_interested,
    preference_count,
    -- Calculate potential revenue based on engagement
    (total_notifications * 0.1 * avg_watch_price_interested) AS estimated_revenue_potential,
    CASE 
        WHEN (total_notifications * 0.1 * avg_watch_price_interested) >= 10000 THEN 'High Value'
        WHEN (total_notifications * 0.1 * avg_watch_price_interested) >= 5000 THEN 'Medium Value'
        WHEN (total_notifications * 0.1 * avg_watch_price_interested) >= 1000 THEN 'Low Value'
        ELSE 'Minimal Value'
    END AS revenue_tier
FROM user_value_metrics
ORDER BY estimated_revenue_potential DESC;

-- =====================================================
-- PREDICTIVE ANALYTICS
-- =====================================================

-- 13. Watch Release Success Prediction Model
CREATE OR REPLACE FUNCTION predict_watch_release_success(
    brand_param TEXT,
    price_param DECIMAL,
    is_limited_edition_param BOOLEAN,
    category_count_param INTEGER,
    feature_count_param INTEGER
)
RETURNS DECIMAL AS $$
DECLARE
    success_probability DECIMAL;
    brand_success_rate DECIMAL;
    price_factor DECIMAL;
    limited_edition_factor DECIMAL;
    category_factor DECIMAL;
    feature_factor DECIMAL;
BEGIN
    -- Get brand success rate
    SELECT 
        COALESCE(
            (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 
            75.0
        )
    INTO brand_success_rate
    FROM watch_releases wr
    LEFT JOIN notifications n ON wr.id = n.watch_release_id
    WHERE wr.brand = brand_param;
    
    -- Calculate price factor (higher price = lower success probability)
    price_factor = CASE 
        WHEN price_param < 1000 THEN 1.0
        WHEN price_param < 5000 THEN 0.9
        WHEN price_param < 10000 THEN 0.8
        WHEN price_param < 50000 THEN 0.7
        ELSE 0.6
    END;
    
    -- Calculate limited edition factor
    limited_edition_factor = CASE 
        WHEN is_limited_edition_param THEN 1.2
        ELSE 1.0
    END;
    
    -- Calculate category factor
    category_factor = CASE 
        WHEN category_count_param >= 3 THEN 1.1
        WHEN category_count_param >= 2 THEN 1.0
        ELSE 0.9
    END;
    
    -- Calculate feature factor
    feature_factor = CASE 
        WHEN feature_count_param >= 5 THEN 1.1
        WHEN feature_count_param >= 3 THEN 1.0
        ELSE 0.9
    END;
    
    -- Calculate overall success probability
    success_probability = brand_success_rate * price_factor * limited_edition_factor * category_factor * feature_factor;
    
    -- Cap at 100%
    RETURN LEAST(success_probability, 100);
END;
$$ LANGUAGE plpgsql;

-- 14. User Engagement Prediction
CREATE OR REPLACE FUNCTION predict_user_engagement(
    user_id_param BIGINT,
    days_forward INTEGER DEFAULT 30
)
RETURNS DECIMAL AS $$
DECLARE
    predicted_engagement DECIMAL;
    current_engagement DECIMAL;
    days_since_registration INTEGER;
    notification_frequency DECIMAL;
    preference_count INTEGER;
BEGIN
    -- Get current engagement score
    SELECT calculate_user_engagement_score(user_id_param) INTO current_engagement;
    
    -- Get days since registration
    SELECT EXTRACT(DAY FROM NOW() - created_at) INTO days_since_registration
    FROM users WHERE id = user_id_param;
    
    -- Get notification frequency (notifications per day)
    SELECT 
        CASE 
            WHEN days_since_registration > 0 THEN COUNT(*)::DECIMAL / days_since_registration
            ELSE 0
        END
    INTO notification_frequency
    FROM notifications 
    WHERE user_id = user_id_param AND status = 'SENT';
    
    -- Get preference count
    SELECT array_length(preferences, 1) INTO preference_count
    FROM users WHERE id = user_id_param;
    
    -- Predict future engagement
    predicted_engagement = current_engagement + 
        (notification_frequency * days_forward * 0.5) + 
        (preference_count * 2) +
        (CASE WHEN days_since_registration < 30 THEN 10 ELSE 0 END);
    
    -- Cap at 100
    RETURN LEAST(predicted_engagement, 100);
END;
$$ LANGUAGE plpgsql;
