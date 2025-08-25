# Analytics and Data Pooling System for Watch Notification Service

This comprehensive analytics system provides deep insights into user behavior, notification performance, and business metrics for the Watch Notification Service using PostgreSQL.

## 📊 **Analytics Overview**

### **🎯 Key Features:**

✅ **User Analytics**: Engagement, retention, segmentation, and behavior analysis  
✅ **Notification Analytics**: Delivery performance, timing optimization, error analysis  
✅ **Business Analytics**: Brand performance, revenue potential, market insights  
✅ **Predictive Analytics**: Success prediction, engagement forecasting  
✅ **Data Warehouse**: Optimized views and materialized views for performance  
✅ **Real-time Dashboards**: Live metrics and KPIs  

## 📁 **File Structure**

```
database/analytics/
├── 01_user_analytics.sql          # User behavior and engagement analysis
├── 02_notification_analytics.sql  # Notification performance and delivery analysis
├── 03_business_analytics.sql      # Business metrics and watch release analysis
├── 04_data_warehouse_views.sql    # Data warehouse and materialized views
├── 05_sample_queries.sql          # Practical usage examples and queries
└── README.md                      # This documentation file
```

## 🚀 **Quick Start**

### **1. Database Setup**

```sql
-- Connect to your PostgreSQL database
\c watchnotify

-- Run the analytics scripts in order
\i database/analytics/01_user_analytics.sql
\i database/analytics/02_notification_analytics.sql
\i database/analytics/03_business_analytics.sql
\i database/analytics/04_data_warehouse_views.sql
```

### **2. Initialize Data Warehouse**

```sql
-- Populate fact tables
SELECT populate_fact_tables();

-- Refresh materialized views
SELECT refresh_analytics_views();
```

### **3. Run Sample Queries**

```sql
-- Get top engaged users
SELECT * FROM top_engaged_users LIMIT 10;

-- Check notification performance
SELECT * FROM notification_delivery_performance;

-- View business metrics
SELECT * FROM monthly_business_metrics;
```

## 📈 **Analytics Categories**

### **👥 User Analytics**

#### **Key Views:**
- `user_registration_trends` - Daily/weekly/monthly registration patterns
- `user_preference_analytics` - Notification preference adoption rates
- `user_category_preferences` - User interest by watch categories
- `user_retention_cohorts` - 30-day cohort retention analysis
- `top_engaged_users` - Most active users with engagement scores
- `user_segments` - User segmentation by activity level
- `user_ltv_analysis` - User lifetime value calculations

#### **Sample Queries:**
```sql
-- User engagement trends
SELECT 
    DATE_TRUNC('week', created_at) AS week,
    COUNT(*) AS new_users,
    AVG(calculate_user_engagement_score(id)) AS avg_engagement
FROM users 
WHERE created_at >= NOW() - INTERVAL '12 weeks'
GROUP BY week
ORDER BY week;

-- User retention by cohort
SELECT 
    cohort_month,
    cohort_size,
    retention_month_1,
    retention_month_2,
    retention_month_3
FROM user_retention_cohorts
ORDER BY cohort_month DESC;
```

### **📧 Notification Analytics**

#### **Key Views:**
- `notification_delivery_performance` - Success rates by notification type
- `notification_volume_trends` - Daily notification volume patterns
- `notification_hourly_performance` - Performance by hour of day
- `notification_daily_performance` - Performance by day of week
- `optimal_notification_timing` - Best times for sending notifications
- `notification_error_analysis` - Error patterns and retry analysis
- `notification_efficiency_dashboard` - Overall efficiency metrics

#### **Sample Queries:**
```sql
-- Notification success rates by type
SELECT 
    notification_type,
    total_notifications,
    success_rate,
    avg_delivery_time_seconds
FROM notification_delivery_performance
ORDER BY success_rate DESC;

-- Optimal sending times
SELECT 
    hour,
    day_name,
    success_rate,
    timing_quality
FROM optimal_notification_timing
WHERE total_notifications >= 10
ORDER BY success_rate DESC;
```

### **💼 Business Analytics**

#### **Key Views:**
- `watch_release_performance` - Individual watch release metrics
- `brand_performance_analysis` - Brand-level performance comparison
- `price_range_performance` - Performance by price segments
- `limited_edition_performance` - Limited vs regular release comparison
- `category_performance_analysis` - Category-level insights
- `monthly_business_metrics` - Monthly business KPIs
- `revenue_potential_analysis` - Revenue forecasting

#### **Sample Queries:**
```sql
-- Brand performance comparison
SELECT 
    brand,
    total_releases,
    avg_price,
    notification_success_rate,
    total_notifications_sent
FROM brand_performance_analysis
ORDER BY total_notifications_sent DESC;

-- Price range analysis
SELECT 
    price_range,
    total_releases,
    avg_price,
    notification_success_rate
FROM price_range_performance
ORDER BY avg_price;
```

### **🔮 Predictive Analytics**

#### **Key Functions:**
- `predict_watch_release_success()` - Predict success probability for new releases
- `predict_user_engagement()` - Forecast user engagement levels
- `calculate_user_engagement_score()` - Calculate current engagement scores

#### **Sample Usage:**
```sql
-- Predict success for a new watch release
SELECT 
    predict_watch_release_success(
        'Rolex',           -- brand
        15000.00,          -- price
        true,              -- is_limited_edition
        3,                 -- category_count
        5                  -- feature_count
    ) AS predicted_success_rate;

-- Predict user engagement
SELECT 
    u.first_name,
    u.last_name,
    calculate_user_engagement_score(u.id) AS current_engagement,
    predict_user_engagement(u.id, 30) AS predicted_engagement_30_days
FROM users u
WHERE u.is_active = true
ORDER BY current_engagement DESC
LIMIT 10;
```

## 🏗️ **Data Warehouse Architecture**

### **Dimension Tables:**
- `dim_date` - Date dimension with calendar attributes
- `dim_user` - User dimension with profile information
- `dim_watch_release` - Watch release dimension with product details

### **Fact Tables:**
- `fact_notifications` - Notification events and metrics
- `fact_user_activity` - User activity tracking

### **Materialized Views:**
- `daily_user_activity_summary` - Daily user activity metrics
- `monthly_business_metrics_summary` - Monthly business KPIs
- `user_engagement_summary` - User engagement metrics
- `watch_release_performance_summary` - Watch release performance

## 📊 **Dashboard Queries**

### **Executive Dashboard**
```sql
-- Comprehensive business overview
WITH business_summary AS (
    SELECT 
        COUNT(DISTINCT u.id) AS total_users,
        COUNT(DISTINCT wr.id) AS total_releases,
        COUNT(n.id) AS total_notifications,
        COUNT(*) FILTER (WHERE n.status = 'SENT') AS successful_notifications,
        SUM(wr.price) AS total_release_value
    FROM users u
    CROSS JOIN watch_releases wr
    LEFT JOIN notifications n ON u.id = n.user_id AND wr.id = n.watch_release_id
    WHERE u.is_active = true
)
SELECT 
    total_users,
    total_releases,
    total_notifications,
    ROUND((successful_notifications::DECIMAL / total_notifications) * 100, 2) AS success_rate,
    total_release_value
FROM business_summary;
```

### **User Engagement Dashboard**
```sql
-- User engagement overview
SELECT 
    user_segment,
    COUNT(*) AS user_count,
    AVG(total_notifications) AS avg_notifications,
    AVG(success_rate) AS avg_success_rate
FROM user_engagement_facts
GROUP BY user_segment
ORDER BY user_count DESC;
```

### **Notification Performance Dashboard**
```sql
-- Notification performance overview
SELECT 
    notification_type,
    total_notifications,
    success_rate,
    efficiency_score,
    efficiency_rating
FROM notification_efficiency_dashboard
ORDER BY efficiency_score DESC;
```

## 🔄 **Maintenance and Refresh**

### **Scheduled Refresh**
```sql
-- Refresh all analytics views
SELECT scheduled_analytics_refresh();

-- Check refresh status
SELECT 
    refresh_time,
    status,
    message
FROM analytics_refresh_log
ORDER BY refresh_time DESC
LIMIT 5;
```

### **Manual Refresh**
```sql
-- Refresh specific materialized views
REFRESH MATERIALIZED VIEW daily_user_activity_summary;
REFRESH MATERIALIZED VIEW monthly_business_metrics_summary;

-- Populate fact tables
SELECT populate_fact_tables();
```

## 📈 **Performance Optimization**

### **Indexes**
The system includes optimized indexes for:
- Date-based queries
- User activity tracking
- Notification performance
- Brand and category analysis

### **Materialized Views**
- Pre-computed aggregations for fast query performance
- Automatic refresh capabilities
- Optimized for dashboard queries

### **Query Optimization Tips**
```sql
-- Use date filters for better performance
WHERE created_at >= NOW() - INTERVAL '30 days'

-- Use materialized views for large aggregations
SELECT * FROM daily_user_activity_summary;

-- Use indexes for user lookups
WHERE user_id = ? AND created_at >= ?
```

## 🎯 **Use Cases**

### **1. User Growth Analysis**
```sql
-- Track user acquisition trends
SELECT 
    DATE_TRUNC('month', created_at) AS month,
    COUNT(*) AS new_users,
    SUM(COUNT(*)) OVER (ORDER BY DATE_TRUNC('month', created_at)) AS cumulative_users
FROM users 
WHERE is_active = true
GROUP BY month
ORDER BY month;
```

### **2. Notification Optimization**
```sql
-- Find optimal sending times
SELECT 
    hour,
    day_name,
    success_rate,
    total_notifications
FROM optimal_notification_timing
WHERE total_notifications >= 10
ORDER BY success_rate DESC;
```

### **3. Revenue Forecasting**
```sql
-- Predict revenue potential
SELECT 
    user_segment,
    COUNT(*) AS user_count,
    AVG(estimated_revenue_potential) AS avg_revenue_potential,
    SUM(estimated_revenue_potential) AS total_revenue_potential
FROM user_ltv_analysis
GROUP BY user_segment
ORDER BY total_revenue_potential DESC;
```

### **4. Brand Performance**
```sql
-- Compare brand performance
SELECT 
    brand,
    total_releases,
    avg_price,
    notification_success_rate,
    total_notifications_sent
FROM brand_performance_analysis
ORDER BY total_notifications_sent DESC;
```

## 🔧 **Configuration**

### **Environment Variables**
```bash
# Database connection
DB_HOST=localhost
DB_PORT=5432
DB_NAME=watchnotify
DB_USERNAME=postgres
DB_PASSWORD=your_password

# Analytics refresh schedule (cron)
ANALYTICS_REFRESH_SCHEDULE="0 2 * * *"  # Daily at 2 AM
```

### **Cron Job Setup**
```bash
# Add to crontab for daily refresh
0 2 * * * psql -h localhost -U postgres -d watchnotify -c "SELECT scheduled_analytics_refresh();"
```

## 📊 **Monitoring and Alerts**

### **Performance Monitoring**
```sql
-- Check materialized view sizes
SELECT 
    matviewname,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||matviewname)) AS size
FROM pg_matviews
WHERE schemaname = 'public';

-- Monitor refresh performance
SELECT 
    refresh_time,
    status,
    message
FROM analytics_refresh_log
WHERE refresh_time >= NOW() - INTERVAL '7 days'
ORDER BY refresh_time DESC;
```

### **Alert Queries**
```sql
-- Low notification success rate alert
SELECT 
    notification_type,
    success_rate
FROM notification_delivery_performance
WHERE success_rate < 90;

-- High error rate alert
SELECT 
    notification_type,
    error_message,
    error_count
FROM notification_error_analysis
WHERE error_count > 10;
```

## 🚨 **Troubleshooting**

### **Common Issues**

#### **1. Slow Query Performance**
```sql
-- Check query execution plan
EXPLAIN ANALYZE SELECT * FROM user_engagement_summary;

-- Refresh materialized views
SELECT refresh_analytics_views();
```

#### **2. Data Staleness**
```sql
-- Check last refresh time
SELECT MAX(refresh_time) FROM analytics_refresh_log;

-- Force refresh
SELECT scheduled_analytics_refresh();
```

#### **3. Memory Issues**
```sql
-- Check materialized view sizes
SELECT 
    matviewname,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||matviewname)) AS size
FROM pg_matviews;
```

## 📚 **Additional Resources**

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostgreSQL Materialized Views](https://www.postgresql.org/docs/current/rules-materializedviews.html)
- [Analytics Best Practices](https://cloud.google.com/architecture/analytics-best-practices)

## 🤝 **Contributing**

1. Follow the existing SQL style and naming conventions
2. Add appropriate indexes for new queries
3. Include sample queries for new views
4. Update this README with new features
5. Test performance impact of new analytics

## 📄 **License**

This analytics system is part of the Watch Notification Service and is licensed under the MIT License.
