-- Notification Analytics and Performance Analysis
-- This script provides comprehensive notification analytics for the Watch Notification Service

-- =====================================================
-- NOTIFICATION DELIVERY ANALYTICS
-- =====================================================

-- 1. Notification Delivery Performance by Type
CREATE OR REPLACE VIEW notification_delivery_performance AS
SELECT 
    notification_type,
    COUNT(*) AS total_notifications,
    COUNT(*) FILTER (WHERE status = 'SENT') AS successful_deliveries,
    COUNT(*) FILTER (WHERE status = 'FAILED') AS failed_deliveries,
    COUNT(*) FILTER (WHERE status = 'PENDING') AS pending_notifications,
    ROUND(
        (COUNT(*) FILTER (WHERE status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS success_rate,
    ROUND(
        (COUNT(*) FILTER (WHERE status = 'FAILED')::DECIMAL / COUNT(*)) * 100, 2
    ) AS failure_rate,
    AVG(EXTRACT(EPOCH FROM (sent_at - created_at))) AS avg_delivery_time_seconds,
    MIN(EXTRACT(EPOCH FROM (sent_at - created_at))) AS min_delivery_time_seconds,
    MAX(EXTRACT(EPOCH FROM (sent_at - created_at))) AS max_delivery_time_seconds
FROM notifications
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY notification_type
ORDER BY success_rate DESC;

-- 2. Notification Volume Trends (Daily, Weekly, Monthly)
CREATE OR REPLACE VIEW notification_volume_trends AS
SELECT 
    DATE_TRUNC('day', created_at) AS notification_date,
    notification_type,
    COUNT(*) AS notification_count,
    COUNT(*) FILTER (WHERE status = 'SENT') AS successful_count,
    COUNT(*) FILTER (WHERE status = 'FAILED') AS failed_count,
    ROUND(
        (COUNT(*) FILTER (WHERE status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS daily_success_rate
FROM notifications
WHERE created_at >= NOW() - INTERVAL '90 days'
GROUP BY DATE_TRUNC('day', created_at), notification_type
ORDER BY notification_date DESC, notification_type;

-- 3. Notification Performance by Hour of Day
CREATE OR REPLACE VIEW notification_hourly_performance AS
SELECT 
    EXTRACT(HOUR FROM created_at) AS hour_of_day,
    notification_type,
    COUNT(*) AS total_notifications,
    COUNT(*) FILTER (WHERE status = 'SENT') AS successful_notifications,
    ROUND(
        (COUNT(*) FILTER (WHERE status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS success_rate,
    AVG(EXTRACT(EPOCH FROM (sent_at - created_at))) AS avg_delivery_time_seconds
FROM notifications
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY EXTRACT(HOUR FROM created_at), notification_type
ORDER BY hour_of_day, notification_type;

-- 4. Notification Performance by Day of Week
CREATE OR REPLACE VIEW notification_daily_performance AS
SELECT 
    TO_CHAR(created_at, 'Day') AS day_of_week,
    EXTRACT(DOW FROM created_at) AS day_number,
    notification_type,
    COUNT(*) AS total_notifications,
    COUNT(*) FILTER (WHERE status = 'SENT') AS successful_notifications,
    ROUND(
        (COUNT(*) FILTER (WHERE status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS success_rate,
    AVG(EXTRACT(EPOCH FROM (sent_at - created_at))) AS avg_delivery_time_seconds
FROM notifications
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY TO_CHAR(created_at, 'Day'), EXTRACT(DOW FROM created_at), notification_type
ORDER BY day_number, notification_type;

-- 5. Notification Retry Analysis
CREATE OR REPLACE VIEW notification_retry_analysis AS
SELECT 
    notification_type,
    retry_count,
    COUNT(*) AS notification_count,
    COUNT(*) FILTER (WHERE status = 'SENT') AS successful_after_retries,
    COUNT(*) FILTER (WHERE status = 'FAILED') AS failed_after_retries,
    ROUND(
        (COUNT(*) FILTER (WHERE status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS success_rate_after_retries,
    AVG(EXTRACT(EPOCH FROM (sent_at - created_at))) AS avg_total_delivery_time_seconds
FROM notifications
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY notification_type, retry_count
ORDER BY notification_type, retry_count;

-- =====================================================
-- NOTIFICATION CONTENT ANALYSIS
-- =====================================================

-- 6. Most Successful Notification Content Analysis
CREATE OR REPLACE VIEW notification_content_analysis AS
WITH content_metrics AS (
    SELECT 
        wr.watch_name,
        wr.brand,
        wr.categories,
        wr.price,
        wr.is_limited_edition,
        COUNT(n.id) AS total_notifications,
        COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications,
        ROUND(
            (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
        ) AS success_rate,
        AVG(EXTRACT(EPOCH FROM (n.sent_at - n.created_at))) AS avg_delivery_time_seconds
    FROM notifications n
    JOIN watch_releases wr ON n.watch_release_id = wr.id
    WHERE n.created_at >= NOW() - INTERVAL '30 days'
    GROUP BY wr.watch_name, wr.brand, wr.categories, wr.price, wr.is_limited_edition
)
SELECT 
    watch_name,
    brand,
    categories,
    price,
    is_limited_edition,
    total_notifications,
    successful_notifications,
    success_rate,
    avg_delivery_time_seconds,
    CASE 
        WHEN success_rate >= 95 THEN 'Excellent'
        WHEN success_rate >= 90 THEN 'Good'
        WHEN success_rate >= 80 THEN 'Average'
        ELSE 'Poor'
    END AS performance_rating
FROM content_metrics
ORDER BY success_rate DESC, total_notifications DESC;

-- 7. Brand Performance Analysis
CREATE OR REPLACE VIEW brand_notification_performance AS
SELECT 
    wr.brand,
    COUNT(n.id) AS total_notifications,
    COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications,
    COUNT(*) FILTER (WHERE n.status = 'FAILED') AS failed_notifications,
    ROUND(
        (COUNT(*) FILTER (WHERE n.status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS success_rate,
    AVG(EXTRACT(EPOCH FROM (n.sent_at - n.created_at))) AS avg_delivery_time_seconds,
    COUNT(DISTINCT wr.id) AS unique_watches,
    COUNT(DISTINCT n.user_id) AS unique_users_notified
FROM notifications n
JOIN watch_releases wr ON n.watch_release_id = wr.id
WHERE n.created_at >= NOW() - INTERVAL '30 days'
GROUP BY wr.brand
ORDER BY success_rate DESC;

-- 8. Category Performance Analysis
CREATE OR REPLACE VIEW category_notification_performance AS
WITH category_notifications AS (
    SELECT 
        n.id,
        n.status,
        n.created_at,
        n.sent_at,
        c.category
    FROM notifications n
    JOIN watch_releases wr ON n.watch_release_id = wr.id
    CROSS JOIN LATERAL unnest(wr.categories) AS c(category)
    WHERE n.created_at >= NOW() - INTERVAL '30 days'
)
SELECT 
    category,
    COUNT(*) AS total_notifications,
    COUNT(*) FILTER (WHERE status = 'SENT') AS successful_notifications,
    COUNT(*) FILTER (WHERE status = 'FAILED') AS failed_notifications,
    ROUND(
        (COUNT(*) FILTER (WHERE status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS success_rate,
    AVG(EXTRACT(EPOCH FROM (sent_at - created_at))) AS avg_delivery_time_seconds
FROM category_notifications
GROUP BY category
ORDER BY success_rate DESC;

-- =====================================================
-- NOTIFICATION TIMING ANALYSIS
-- =====================================================

-- 9. Optimal Notification Timing Analysis
CREATE OR REPLACE VIEW optimal_notification_timing AS
WITH timing_metrics AS (
    SELECT 
        EXTRACT(HOUR FROM created_at) AS hour,
        EXTRACT(DOW FROM created_at) AS day_of_week,
        notification_type,
        COUNT(*) AS total_notifications,
        COUNT(*) FILTER (WHERE status = 'SENT') AS successful_notifications,
        ROUND(
            (COUNT(*) FILTER (WHERE status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
        ) AS success_rate,
        AVG(EXTRACT(EPOCH FROM (sent_at - created_at))) AS avg_delivery_time_seconds
    FROM notifications
    WHERE created_at >= NOW() - INTERVAL '30 days'
    GROUP BY EXTRACT(HOUR FROM created_at), EXTRACT(DOW FROM created_at), notification_type
)
SELECT 
    hour,
    CASE day_of_week
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
    notification_type,
    total_notifications,
    successful_notifications,
    success_rate,
    avg_delivery_time_seconds,
    CASE 
        WHEN success_rate >= 95 THEN 'Optimal'
        WHEN success_rate >= 90 THEN 'Good'
        WHEN success_rate >= 80 THEN 'Acceptable'
        ELSE 'Poor'
    END AS timing_quality
FROM timing_metrics
ORDER BY success_rate DESC, total_notifications DESC;

-- 10. Notification Queue Performance
CREATE OR REPLACE VIEW notification_queue_performance AS
SELECT 
    DATE_TRUNC('hour', created_at) AS queue_hour,
    notification_type,
    COUNT(*) AS queued_notifications,
    COUNT(*) FILTER (WHERE status = 'SENT') AS processed_notifications,
    COUNT(*) FILTER (WHERE status = 'PENDING') AS pending_notifications,
    COUNT(*) FILTER (WHERE status = 'FAILED') AS failed_notifications,
    ROUND(
        (COUNT(*) FILTER (WHERE status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS processing_rate,
    AVG(EXTRACT(EPOCH FROM (sent_at - created_at))) AS avg_processing_time_seconds,
    MAX(EXTRACT(EPOCH FROM (sent_at - created_at))) AS max_processing_time_seconds
FROM notifications
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE_TRUNC('hour', created_at), notification_type
ORDER BY queue_hour DESC, notification_type;

-- =====================================================
-- NOTIFICATION ERROR ANALYSIS
-- =====================================================

-- 11. Notification Error Analysis
CREATE OR REPLACE VIEW notification_error_analysis AS
SELECT 
    notification_type,
    error_message,
    COUNT(*) AS error_count,
    COUNT(*) FILTER (WHERE retry_count = 0) AS first_attempt_failures,
    COUNT(*) FILTER (WHERE retry_count > 0) AS retry_failures,
    AVG(retry_count) AS avg_retry_attempts,
    MAX(retry_count) AS max_retry_attempts,
    MIN(created_at) AS first_error_occurrence,
    MAX(created_at) AS last_error_occurrence
FROM notifications
WHERE status = 'FAILED' AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY notification_type, error_message
ORDER BY error_count DESC;

-- 12. Notification Failure Patterns
CREATE OR REPLACE VIEW notification_failure_patterns AS
SELECT 
    DATE_TRUNC('day', created_at) AS failure_date,
    notification_type,
    COUNT(*) AS failure_count,
    COUNT(DISTINCT user_id) AS affected_users,
    COUNT(DISTINCT watch_release_id) AS affected_watches,
    AVG(retry_count) AS avg_retry_attempts,
    STRING_AGG(DISTINCT error_message, '; ') AS error_messages
FROM notifications
WHERE status = 'FAILED' AND created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', created_at), notification_type
ORDER BY failure_date DESC, failure_count DESC;

-- =====================================================
-- NOTIFICATION EFFICIENCY METRICS
-- =====================================================

-- 13. Notification Efficiency Score
CREATE OR REPLACE FUNCTION calculate_notification_efficiency_score(
    notification_type_param TEXT,
    days_back INTEGER DEFAULT 30
)
RETURNS DECIMAL AS $$
DECLARE
    efficiency_score DECIMAL;
    success_rate DECIMAL;
    avg_delivery_time DECIMAL;
    retry_rate DECIMAL;
BEGIN
    -- Calculate success rate
    SELECT 
        (COUNT(*) FILTER (WHERE status = 'SENT')::DECIMAL / COUNT(*)) * 100
    INTO success_rate
    FROM notifications
    WHERE notification_type = notification_type_param 
    AND created_at >= NOW() - (days_back || ' days')::INTERVAL;
    
    -- Calculate average delivery time (in seconds)
    SELECT AVG(EXTRACT(EPOCH FROM (sent_at - created_at)))
    INTO avg_delivery_time
    FROM notifications
    WHERE notification_type = notification_type_param 
    AND status = 'SENT'
    AND created_at >= NOW() - (days_back || ' days')::INTERVAL;
    
    -- Calculate retry rate
    SELECT 
        (COUNT(*) FILTER (WHERE retry_count > 0)::DECIMAL / COUNT(*)) * 100
    INTO retry_rate
    FROM notifications
    WHERE notification_type = notification_type_param 
    AND created_at >= NOW() - (days_back || ' days')::INTERVAL;
    
    -- Calculate efficiency score (0-100)
    efficiency_score = (
        (success_rate * 0.5) + 
        (CASE WHEN avg_delivery_time <= 60 THEN 25 
              WHEN avg_delivery_time <= 300 THEN 15 
              ELSE 5 END) +
        (CASE WHEN retry_rate <= 5 THEN 25 
              WHEN retry_rate <= 15 THEN 15 
              ELSE 5 END)
    );
    
    RETURN LEAST(efficiency_score, 100);
END;
$$ LANGUAGE plpgsql;

-- 14. Notification Efficiency Dashboard
CREATE OR REPLACE VIEW notification_efficiency_dashboard AS
SELECT 
    notification_type,
    COUNT(*) AS total_notifications,
    COUNT(*) FILTER (WHERE status = 'SENT') AS successful_notifications,
    ROUND(
        (COUNT(*) FILTER (WHERE status = 'SENT')::DECIMAL / COUNT(*)) * 100, 2
    ) AS success_rate,
    AVG(EXTRACT(EPOCH FROM (sent_at - created_at))) AS avg_delivery_time_seconds,
    AVG(retry_count) AS avg_retry_count,
    calculate_notification_efficiency_score(notification_type) AS efficiency_score,
    CASE 
        WHEN calculate_notification_efficiency_score(notification_type) >= 90 THEN 'Excellent'
        WHEN calculate_notification_efficiency_score(notification_type) >= 80 THEN 'Good'
        WHEN calculate_notification_efficiency_score(notification_type) >= 70 THEN 'Average'
        ELSE 'Poor'
    END AS efficiency_rating
FROM notifications
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY notification_type
ORDER BY efficiency_score DESC;
