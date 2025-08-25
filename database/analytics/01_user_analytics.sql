-- User Analytics and Behavior Analysis
-- This script provides comprehensive user analytics for the Watch Notification Service

-- =====================================================
-- USER ENGAGEMENT ANALYTICS
-- =====================================================

-- 1. User Registration Trends (Daily, Weekly, Monthly)
CREATE OR REPLACE VIEW user_registration_trends AS
SELECT 
    DATE_TRUNC('day', created_at) AS registration_date,
    COUNT(*) AS new_users,
    SUM(COUNT(*)) OVER (ORDER BY DATE_TRUNC('day', created_at)) AS cumulative_users
FROM users 
WHERE is_active = true
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY registration_date;

-- 2. User Activity by Notification Preferences
CREATE OR REPLACE VIEW user_preference_analytics AS
SELECT 
    'Email Notifications' AS preference_type,
    COUNT(*) AS total_users,
    COUNT(*) FILTER (WHERE email_notifications_enabled = true) AS enabled_users,
    ROUND(
        (COUNT(*) FILTER (WHERE email_notifications_enabled = true)::DECIMAL / COUNT(*)) * 100, 2
    ) AS adoption_rate
FROM users 
WHERE is_active = true

UNION ALL

SELECT 
    'SMS Notifications' AS preference_type,
    COUNT(*) AS total_users,
    COUNT(*) FILTER (WHERE sms_notifications_enabled = true) AS enabled_users,
    ROUND(
        (COUNT(*) FILTER (WHERE sms_notifications_enabled = true)::DECIMAL / COUNT(*)) * 100, 2
    ) AS adoption_rate
FROM users 
WHERE is_active = true

UNION ALL

SELECT 
    'Push Notifications' AS preference_type,
    COUNT(*) AS total_users,
    COUNT(*) FILTER (WHERE push_notifications_enabled = true) AS enabled_users,
    ROUND(
        (COUNT(*) FILTER (WHERE push_notifications_enabled = true)::DECIMAL / COUNT(*)) * 100, 2
    ) AS adoption_rate
FROM users 
WHERE is_active = true;

-- 3. User Preference Analysis by Category
CREATE OR REPLACE VIEW user_category_preferences AS
WITH user_prefs AS (
    SELECT 
        u.id,
        u.first_name,
        u.last_name,
        u.email,
        p.preference
    FROM users u
    CROSS JOIN LATERAL unnest(u.preferences) AS p(preference)
    WHERE u.is_active = true
)
SELECT 
    preference AS category,
    COUNT(*) AS user_count,
    ROUND((COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM users WHERE is_active = true)) * 100, 2) AS percentage
FROM user_prefs
GROUP BY preference
ORDER BY user_count DESC;

-- 4. User Retention Analysis (30-day cohorts)
CREATE OR REPLACE VIEW user_retention_cohorts AS
WITH user_cohorts AS (
    SELECT 
        id,
        created_at,
        DATE_TRUNC('month', created_at) AS cohort_month,
        DATE_TRUNC('month', created_at) + INTERVAL '1 month' - INTERVAL '1 day' AS cohort_end
    FROM users 
    WHERE is_active = true
),
user_activity AS (
    SELECT DISTINCT
        n.user_id,
        DATE_TRUNC('month', n.created_at) AS activity_month
    FROM notifications n
    WHERE n.status = 'SENT'
),
cohort_retention AS (
    SELECT 
        c.cohort_month,
        COUNT(DISTINCT c.id) AS cohort_size,
        COUNT(DISTINCT CASE WHEN a.activity_month = c.cohort_month THEN c.id END) AS month_0,
        COUNT(DISTINCT CASE WHEN a.activity_month = c.cohort_month + INTERVAL '1 month' THEN c.id END) AS month_1,
        COUNT(DISTINCT CASE WHEN a.activity_month = c.cohort_month + INTERVAL '2 months' THEN c.id END) AS month_2,
        COUNT(DISTINCT CASE WHEN a.activity_month = c.cohort_month + INTERVAL '3 months' THEN c.id END) AS month_3
    FROM user_cohorts c
    LEFT JOIN user_activity a ON c.id = a.user_id
    GROUP BY c.cohort_month
)
SELECT 
    cohort_month,
    cohort_size,
    month_0,
    month_1,
    month_2,
    month_3,
    ROUND((month_0::DECIMAL / cohort_size) * 100, 2) AS retention_month_0,
    ROUND((month_1::DECIMAL / cohort_size) * 100, 2) AS retention_month_1,
    ROUND((month_2::DECIMAL / cohort_size) * 100, 2) AS retention_month_2,
    ROUND((month_3::DECIMAL / cohort_size) * 100, 2) AS retention_month_3
FROM cohort_retention
ORDER BY cohort_month;

-- 5. User Engagement Score
CREATE OR REPLACE FUNCTION calculate_user_engagement_score(user_id_param BIGINT)
RETURNS DECIMAL AS $$
DECLARE
    engagement_score DECIMAL;
    notification_count INTEGER;
    days_since_registration INTEGER;
    preference_count INTEGER;
BEGIN
    -- Get notification count
    SELECT COUNT(*) INTO notification_count
    FROM notifications 
    WHERE user_id = user_id_param AND status = 'SENT';
    
    -- Get days since registration
    SELECT EXTRACT(DAY FROM NOW() - created_at) INTO days_since_registration
    FROM users WHERE id = user_id_param;
    
    -- Get preference count
    SELECT array_length(preferences, 1) INTO preference_count
    FROM users WHERE id = user_id_param;
    
    -- Calculate engagement score (0-100)
    engagement_score = (
        (notification_count * 10) + 
        (preference_count * 5) + 
        (CASE WHEN days_since_registration > 0 THEN 100 / days_since_registration ELSE 0 END)
    );
    
    -- Cap at 100
    RETURN LEAST(engagement_score, 100);
END;
$$ LANGUAGE plpgsql;

-- 6. Top Engaged Users
CREATE OR REPLACE VIEW top_engaged_users AS
SELECT 
    u.id,
    u.first_name,
    u.last_name,
    u.email,
    calculate_user_engagement_score(u.id) AS engagement_score,
    COUNT(n.id) AS total_notifications,
    array_length(u.preferences, 1) AS preference_count,
    u.created_at,
    CASE 
        WHEN calculate_user_engagement_score(u.id) >= 80 THEN 'High'
        WHEN calculate_user_engagement_score(u.id) >= 50 THEN 'Medium'
        ELSE 'Low'
    END AS engagement_level
FROM users u
LEFT JOIN notifications n ON u.id = n.user_id AND n.status = 'SENT'
WHERE u.is_active = true
GROUP BY u.id, u.first_name, u.last_name, u.email, u.preferences, u.created_at
ORDER BY engagement_score DESC;

-- =====================================================
-- USER SEGMENTATION
-- =====================================================

-- 7. User Segmentation by Activity
CREATE OR REPLACE VIEW user_segments AS
WITH user_activity_stats AS (
    SELECT 
        u.id,
        u.first_name,
        u.last_name,
        u.email,
        COUNT(n.id) AS notification_count,
        MAX(n.created_at) AS last_activity,
        EXTRACT(DAY FROM NOW() - u.created_at) AS days_since_registration,
        array_length(u.preferences, 1) AS preference_count
    FROM users u
    LEFT JOIN notifications n ON u.id = n.user_id AND n.status = 'SENT'
    WHERE u.is_active = true
    GROUP BY u.id, u.first_name, u.last_name, u.email, u.preferences, u.created_at
)
SELECT 
    id,
    first_name,
    last_name,
    email,
    notification_count,
    last_activity,
    days_since_registration,
    preference_count,
    CASE 
        WHEN notification_count >= 20 AND days_since_registration <= 30 THEN 'Power User'
        WHEN notification_count >= 10 AND days_since_registration <= 60 THEN 'Active User'
        WHEN notification_count >= 5 AND days_since_registration <= 90 THEN 'Regular User'
        WHEN notification_count > 0 THEN 'Occasional User'
        ELSE 'Inactive User'
    END AS user_segment
FROM user_activity_stats
ORDER BY notification_count DESC;

-- 8. Geographic User Distribution (if phone numbers are available)
CREATE OR REPLACE VIEW geographic_user_distribution AS
SELECT 
    CASE 
        WHEN phone_number LIKE '+1%' THEN 'North America'
        WHEN phone_number LIKE '+44%' THEN 'United Kingdom'
        WHEN phone_number LIKE '+33%' THEN 'France'
        WHEN phone_number LIKE '+49%' THEN 'Germany'
        WHEN phone_number LIKE '+81%' THEN 'Japan'
        WHEN phone_number LIKE '+86%' THEN 'China'
        WHEN phone_number LIKE '+91%' THEN 'India'
        WHEN phone_number LIKE '+61%' THEN 'Australia'
        ELSE 'Other'
    END AS region,
    COUNT(*) AS user_count,
    ROUND((COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM users WHERE is_active = true)) * 100, 2) AS percentage
FROM users 
WHERE is_active = true AND phone_number IS NOT NULL
GROUP BY region
ORDER BY user_count DESC;

-- =====================================================
-- USER BEHAVIOR INSIGHTS
-- =====================================================

-- 9. User Response Time Analysis
CREATE OR REPLACE VIEW user_response_analysis AS
SELECT 
    u.id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(n.id) AS total_notifications,
    AVG(EXTRACT(EPOCH FROM (n.sent_at - n.created_at))) AS avg_response_time_seconds,
    MIN(EXTRACT(EPOCH FROM (n.sent_at - n.created_at))) AS min_response_time_seconds,
    MAX(EXTRACT(EPOCH FROM (n.sent_at - n.created_at))) AS max_response_time_seconds,
    COUNT(CASE WHEN n.status = 'SENT' THEN 1 END) AS successful_notifications,
    COUNT(CASE WHEN n.status = 'FAILED' THEN 1 END) AS failed_notifications,
    ROUND(
        (COUNT(CASE WHEN n.status = 'SENT' THEN 1 END)::DECIMAL / COUNT(*)) * 100, 2
    ) AS success_rate
FROM users u
LEFT JOIN notifications n ON u.id = n.user_id
WHERE u.is_active = true
GROUP BY u.id, u.first_name, u.last_name, u.email
HAVING COUNT(n.id) > 0
ORDER BY success_rate DESC;

-- 10. User Lifetime Value (LTV) Calculation
CREATE OR REPLACE VIEW user_ltv_analysis AS
WITH user_metrics AS (
    SELECT 
        u.id,
        u.first_name,
        u.last_name,
        u.email,
        u.created_at,
        COUNT(n.id) AS total_notifications,
        COUNT(DISTINCT wr.id) AS unique_watches_interested,
        array_length(u.preferences, 1) AS preference_count,
        EXTRACT(DAY FROM NOW() - u.created_at) AS days_since_registration
    FROM users u
    LEFT JOIN notifications n ON u.id = n.user_id AND n.status = 'SENT'
    LEFT JOIN watch_releases wr ON n.watch_release_id = wr.id
    WHERE u.is_active = true
    GROUP BY u.id, u.first_name, u.last_name, u.email, u.created_at, u.preferences
)
SELECT 
    id,
    first_name,
    last_name,
    email,
    created_at,
    total_notifications,
    unique_watches_interested,
    preference_count,
    days_since_registration,
    -- Calculate LTV based on engagement metrics
    (total_notifications * 0.5) + 
    (unique_watches_interested * 2.0) + 
    (preference_count * 1.0) + 
    (CASE WHEN days_since_registration > 0 THEN 100 / days_since_registration ELSE 0 END) AS estimated_ltv,
    CASE 
        WHEN (total_notifications * 0.5) + (unique_watches_interested * 2.0) + (preference_count * 1.0) >= 50 THEN 'High Value'
        WHEN (total_notifications * 0.5) + (unique_watches_interested * 2.0) + (preference_count * 1.0) >= 20 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS ltv_tier
FROM user_metrics
ORDER BY estimated_ltv DESC;
