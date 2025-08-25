# Terraform Infrastructure for Watch Notification Service

This Terraform configuration deploys the Watch Notification Service to Google Cloud Platform (GCP) with a complete production-ready infrastructure.

## 🏗️ Infrastructure Components

- **Cloud Run**: Serverless container platform for the Spring Boot application
- **Cloud SQL (PostgreSQL)**: Managed database service
- **Secret Manager**: Secure storage for sensitive configuration
- **Cloud Build**: CI/CD pipeline for automated deployments
- **Cloud Scheduler**: Automated notification tasks
- **Cloud Monitoring**: Application monitoring and alerting
- **Cloud Logging**: Centralized logging with BigQuery export
- **VPC Network**: Isolated network infrastructure
- **Cloud Storage**: Artifact storage and backup

## 📋 Prerequisites

1. **Google Cloud Project**: Create a new GCP project or use an existing one
2. **Terraform**: Install Terraform (version >= 1.0)
3. **Google Cloud SDK**: Install and configure gcloud CLI
4. **Billing**: Enable billing for your GCP project
5. **IAM Permissions**: Ensure you have the necessary permissions

### Required IAM Roles

```bash
# Enable required APIs
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com \
  sql-component.googleapis.com \
  sqladmin.googleapis.com \
  cloudbuild.googleapis.com \
  run.googleapis.com \
  secretmanager.googleapis.com \
  cloudkms.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  pubsub.googleapis.com

# Grant necessary roles to your user/service account
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="user:YOUR_EMAIL" \
  --role="roles/editor"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="user:YOUR_EMAIL" \
  --role="roles/secretmanager.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="user:YOUR_EMAIL" \
  --role="roles/cloudbuild.builds.builder"
```

## 🚀 Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd terraform

# Copy the example variables file
cp terraform.tfvars.example terraform.tfvars
```

### 2. Configure Variables

Edit `terraform.tfvars` with your specific values:

```hcl
project_id = "your-gcp-project-id"
region     = "us-central1"
zone       = "us-central1-a"

# GitHub repository information
github_owner = "your-github-username"
github_repo  = "cloud-native-miroservice-platform"

# Database configuration
db_password = "your-secure-db-password"

# Email configuration (for SMTP)
mail_username = "your-email@gmail.com"
mail_password = "your-app-password"

# Application admin password
admin_password = "your-secure-admin-password"
```

### 3. Initialize Terraform

```bash
# Initialize Terraform
terraform init

# Verify the configuration
terraform plan
```

### 4. Deploy Infrastructure

```bash
# Deploy the infrastructure
terraform apply

# Confirm the deployment when prompted
```

### 5. Access Your Application

After deployment, you'll see output similar to:

```
cloud_run_service_url = "https://watch-notification-service-xxxxx-uc.a.run.app"
```

Access your application at the provided URL.

## 🔧 Configuration Options

### Environment-Specific Configurations

#### Development Environment
```hcl
environment = "dev"
db_instance_tier = "db-f1-micro"
cloud_run_cpu = "1000m"
cloud_run_memory = "512Mi"
```

#### Production Environment
```hcl
environment = "prod"
db_instance_tier = "db-n1-standard-2"
cloud_run_cpu = "2000m"
cloud_run_memory = "1Gi"
cloud_run_min_scale = 1
```

### Database Configuration

```hcl
# Database backup settings
backup_retention_days = 7
maintenance_window_day = 7  # Sunday
maintenance_window_hour = 3 # 3 AM

# Database instance tier
db_instance_tier = "db-f1-micro"  # For development
# db_instance_tier = "db-n1-standard-2"  # For production
```

### Cloud Run Configuration

```hcl
# Resource allocation
cloud_run_cpu = "1000m"
cloud_run_memory = "512Mi"

# Scaling configuration
cloud_run_max_scale = 10
cloud_run_min_scale = 0  # Set to 1 for production
```

## 🔐 Security Configuration

### Secret Management

All sensitive data is stored in Google Secret Manager:

- Database passwords
- Email credentials
- Admin passwords

### Network Security

- VPC with isolated subnet
- Cloud SQL with SSL enabled
- Cloud Run with proper IAM policies

### Access Control

```bash
# Restrict Cloud Run access (optional)
gcloud run services add-iam-policy-binding watch-notification-service \
  --region=us-central1 \
  --member="user:YOUR_EMAIL" \
  --role="roles/run.invoker"
```

## 📊 Monitoring and Logging

### Cloud Monitoring Dashboard

The deployment creates a monitoring dashboard with:
- Request count metrics
- Response time metrics
- Error rates
- Resource utilization

### Logging

- Application logs are automatically collected
- Logs are exported to BigQuery for analysis
- Log retention and lifecycle policies are configured

### Alerting (Optional)

Create alerting policies:

```bash
# Create alerting policy for high error rate
gcloud alpha monitoring policies create \
  --policy-from-file=alerting-policy.yaml
```

## 🔄 CI/CD Pipeline

### Automated Deployment

The Cloud Build trigger automatically:
1. Builds the Spring Boot application
2. Creates a Docker image
3. Pushes to Container Registry
4. Deploys to Cloud Run

### Manual Deployment

```bash
# Build and deploy manually
gcloud builds submit --config=cloudbuild.yaml

# Or deploy directly to Cloud Run
gcloud run deploy watch-notification-service \
  --image gcr.io/YOUR_PROJECT_ID/watch-notification-service:latest \
  --region us-central1 \
  --platform managed
```

## 🧹 Cleanup

### Destroy Infrastructure

```bash
# Destroy all resources
terraform destroy

# Confirm destruction when prompted
```

### Manual Cleanup

```bash
# Delete Cloud Run service
gcloud run services delete watch-notification-service --region=us-central1

# Delete Cloud SQL instance
gcloud sql instances delete watch-notify-postgres

# Delete Cloud Storage bucket
gsutil rm -r gs://watch-notify-app-YOUR_PROJECT_ID
```

## 📈 Scaling and Performance

### Auto-scaling

Cloud Run automatically scales based on:
- Request volume
- CPU utilization
- Memory usage

### Performance Tuning

```hcl
# Increase resources for better performance
cloud_run_cpu = "2000m"
cloud_run_memory = "1Gi"
cloud_run_max_scale = 20

# Database optimization
db_instance_tier = "db-n1-standard-4"
```

## 🔍 Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   # Ensure you have the necessary roles
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **API Not Enabled**
   ```bash
   # Enable required APIs
   gcloud services enable run.googleapis.com
   ```

3. **Database Connection Issues**
   ```bash
   # Check database status
   gcloud sql instances describe watch-notify-postgres
   ```

### Debug Commands

```bash
# Check Cloud Run service status
gcloud run services describe watch-notification-service --region=us-central1

# View application logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=watch-notification-service" --limit=50

# Check Cloud Build status
gcloud builds list --limit=10
```

## 📚 Additional Resources

- [Terraform Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [Secret Manager Documentation](https://cloud.google.com/secret-manager/docs)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.
