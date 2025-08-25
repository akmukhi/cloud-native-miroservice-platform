# Watch Notification Service

A Spring Boot microservice for notifying users about new wrist watch releases via email, SMS, and push notifications.

## Features

- **User Management**: Register and manage users with notification preferences
- **Watch Release Management**: Add and manage new watch releases
- **Multi-channel Notifications**: Send notifications via email, SMS, and push notifications
- **Scheduled Notifications**: Automatic notification sending for new releases
- **Preference-based Targeting**: Send notifications based on user preferences and watch categories
- **Notification History**: Track and monitor notification delivery status
- **RESTful API**: Complete REST API for all operations
- **Database Support**: H2 (development) and PostgreSQL (production)

## Technology Stack

- **Java 17**
- **Spring Boot 3.2.0**
- **Spring Data JPA**
- **Spring Security**
- **Spring Mail**
- **H2 Database** (Development)
- **PostgreSQL** (Production)
- **Lombok**
- **Maven**

## Prerequisites

- Java 17 or higher
- Maven 3.6+
- PostgreSQL (for production)

## Quick Start

### 1. Clone and Build

```bash
cd backend
mvn clean install
```

### 2. Run the Application

#### Development Mode (with H2 database)
```bash
mvn spring-boot:run
```

#### Production Mode (with PostgreSQL)
```bash
mvn spring-boot:run -Dspring.profiles.active=prod
```

### 3. Access the Application

- **Application**: http://localhost:8080
- **H2 Console**: http://localhost:8080/h2-console
- **Actuator Health**: http://localhost:8080/actuator/health

### 4. Default Credentials

- **Username**: admin
- **Password**: admin123

## API Documentation

### Base URL
```
http://localhost:8080/api
```

### Authentication
All API endpoints require basic authentication using the default credentials.

### User Management

#### Get All Users
```http
GET /api/users
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

#### Create User
```http
POST /api/users
Content-Type: application/json
Authorization: Basic YWRtaW46YWRtaW4xMjM=

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+1234567890",
  "emailNotificationsEnabled": true,
  "smsNotificationsEnabled": false,
  "pushNotificationsEnabled": true,
  "preferences": ["luxury", "automatic", "swiss"]
}
```

#### Get User by ID
```http
GET /api/users/{id}
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

#### Update User
```http
PUT /api/users/{id}
Content-Type: application/json
Authorization: Basic YWRtaW46YWRtaW4xMjM=

{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+1234567890",
  "emailNotificationsEnabled": true,
  "smsNotificationsEnabled": true,
  "pushNotificationsEnabled": true,
  "preferences": ["luxury", "automatic", "swiss", "dive"]
}
```

#### Delete User
```http
DELETE /api/users/{id}
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

### Watch Release Management

#### Get All Watch Releases
```http
GET /api/watch-releases
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

#### Create Watch Release
```http
POST /api/watch-releases
Content-Type: application/json
Authorization: Basic YWRtaW46YWRtaW4xMjM=

{
  "watchName": "Chronograph Master",
  "brand": "Swiss Luxury",
  "modelNumber": "SL-2024-001",
  "description": "A premium automatic chronograph with moon phase complication",
  "releaseDate": "2024-01-15T10:00:00",
  "price": 8500.00,
  "currency": "USD",
  "features": ["automatic", "chronograph", "moon-phase", "sapphire-crystal"],
  "categories": ["luxury", "swiss", "automatic"],
  "imageUrl": "https://example.com/images/chronograph-master.jpg",
  "productUrl": "https://example.com/watches/chronograph-master",
  "isLimitedEdition": true,
  "limitedQuantity": 500
}
```

#### Get Watch Release by ID
```http
GET /api/watch-releases/{id}
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

#### Update Watch Release
```http
PUT /api/watch-releases/{id}
Content-Type: application/json
Authorization: Basic YWRtaW46YWRtaW4xMjM=

{
  "watchName": "Chronograph Master Pro",
  "brand": "Swiss Luxury",
  "modelNumber": "SL-2024-001",
  "description": "A premium automatic chronograph with moon phase complication",
  "releaseDate": "2024-01-15T10:00:00",
  "price": 9000.00,
  "currency": "USD",
  "features": ["automatic", "chronograph", "moon-phase", "sapphire-crystal", "power-reserve"],
  "categories": ["luxury", "swiss", "automatic"],
  "imageUrl": "https://example.com/images/chronograph-master.jpg",
  "productUrl": "https://example.com/watches/chronograph-master",
  "isLimitedEdition": true,
  "limitedQuantity": 500
}
```

#### Delete Watch Release
```http
DELETE /api/watch-releases/{id}
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

#### Get Unnotified Releases
```http
GET /api/watch-releases/unnotified
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

#### Get Releases by Brand
```http
GET /api/watch-releases/brand/{brand}
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

#### Get Upcoming Releases
```http
GET /api/watch-releases/upcoming
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

#### Get Limited Edition Releases
```http
GET /api/watch-releases/limited-edition
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

### Notification Management

#### Send Notifications
```http
POST /api/notifications/send
Content-Type: application/json
Authorization: Basic YWRtaW46YWRtaW4xMjM=

{
  "watchReleaseId": 1,
  "categories": ["luxury", "automatic"],
  "brands": ["Swiss Luxury"],
  "sendEmail": true,
  "sendSms": false,
  "sendPush": true,
  "customMessage": "A new luxury watch is now available!"
}
```

#### Get User Notifications
```http
GET /api/notifications/user/{userId}
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

#### Get Notifications by Status
```http
GET /api/notifications/status/{status}
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

#### Get Notification Count for User
```http
GET /api/notifications/user/{userId}/count
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

## Configuration

### Environment Variables

#### Development (H2)
No additional environment variables required.

#### Production (PostgreSQL)
```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=watchnotify
export DB_USERNAME=postgres
export DB_PASSWORD=your_password
export MAIL_USERNAME=your_email@gmail.com
export MAIL_PASSWORD=your_app_password
export ADMIN_USERNAME=admin
export ADMIN_PASSWORD=secure_password
```

### Email Configuration

To enable email notifications, configure your email settings in `application.yml`:

```yaml
spring:
  mail:
    host: smtp.gmail.com
    port: 587
    username: ${MAIL_USERNAME}
    password: ${MAIL_PASSWORD}
    properties:
      mail:
        smtp:
          auth: true
          starttls:
            enable: true
```

For Gmail, you'll need to:
1. Enable 2-factor authentication
2. Generate an App Password
3. Use the App Password in the configuration

## Scheduled Tasks

The application includes several scheduled tasks:

1. **New Release Notifications** (every 30 minutes)
   - Checks for unnotified watch releases
   - Sends notifications to eligible users

2. **Upcoming Release Reminders** (every hour)
   - Sends reminder notifications for upcoming releases

3. **Limited Edition Alerts** (every 15 minutes)
   - Sends urgent notifications for limited edition releases

## Database Schema

### Users Table
- `id` (Primary Key)
- `first_name`
- `last_name`
- `email` (Unique)
- `phone_number`
- `is_active`
- `email_notifications_enabled`
- `sms_notifications_enabled`
- `push_notifications_enabled`
- `created_at`
- `updated_at`

### User Preferences Table
- `user_id` (Foreign Key)
- `preference`

### Watch Releases Table
- `id` (Primary Key)
- `watch_name`
- `brand`
- `model_number`
- `description`
- `release_date`
- `price`
- `currency`
- `image_url`
- `product_url`
- `is_limited_edition`
- `limited_quantity`
- `is_notified`
- `notification_sent_at`
- `created_at`
- `updated_at`

### Watch Features Table
- `watch_id` (Foreign Key)
- `feature`

### Watch Categories Table
- `watch_id` (Foreign Key)
- `category`

### Notifications Table
- `id` (Primary Key)
- `user_id` (Foreign Key)
- `watch_release_id` (Foreign Key)
- `notification_type` (EMAIL, SMS, PUSH)
- `status` (PENDING, SENT, FAILED, CANCELLED)
- `subject`
- `message`
- `recipient`
- `sent_at`
- `error_message`
- `retry_count`
- `created_at`

## Testing

### Run Tests
```bash
mvn test
```

### Test Endpoints

#### Test Email Notification
```http
POST /api/notifications/test-email?email=test@example.com
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

#### Test SMS Notification
```http
POST /api/notifications/test-sms?phoneNumber=+1234567890
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

#### Test Push Notification
```http
POST /api/notifications/test-push?userId=1
Authorization: Basic YWRtaW46YWRtaW4xMjM=
```

## Monitoring

### Health Check
```http
GET /actuator/health
```

### Metrics
```http
GET /actuator/metrics
```

### Application Info
```http
GET /actuator/info
```

## Deployment

### Docker

Create a `Dockerfile`:

```dockerfile
FROM openjdk:17-jdk-slim
COPY target/watch-notification-service-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

Build and run:
```bash
docker build -t watch-notification-service .
docker run -p 8080:8080 watch-notification-service
```

### Kubernetes

Create deployment and service manifests for Kubernetes deployment.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License.
