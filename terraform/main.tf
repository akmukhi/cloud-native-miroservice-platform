terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }
  
  backend "gcs" {
    bucket = "watch-notify-terraform-state"
    prefix = "terraform/state"
  }
}

# Configure the Google Provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudkms.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "pubsub.googleapis.com"
  ])
  
  service = each.value
  disable_on_destroy = false
}

# Create VPC Network
resource "google_compute_network" "vpc" {
  name                    = "watch-notify-vpc"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.required_apis]
}

# Create Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "watch-notify-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc.id
  region        = var.region
  
  # Enable flow logs for network monitoring
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling       = 0.5
    metadata           = "INCLUDE_ALL_METADATA"
  }
}

# Create Cloud SQL Instance (PostgreSQL)
resource "google_sql_database_instance" "postgres" {
  name             = "watch-notify-postgres"
  database_version = "POSTGRES_15"
  region           = var.region
  
  settings {
    tier = "db-f1-micro"  # Small instance for development, change for production
    
    backup_configuration {
      enabled    = true
      start_time = "02:00"
      
      backup_retention_settings {
        retained_backups = 7
      }
    }
    
    ip_configuration {
      ipv4_enabled    = true
      require_ssl     = true
      authorized_networks {
        name  = "all"
        value = "0.0.0.0/0"  # In production, restrict this to your VPC
      }
    }
    
    maintenance_window {
      day          = 7  # Sunday
      hour         = 3  # 3 AM
      update_track = "stable"
    }
  }
  
  deletion_protection = false  # Set to true in production
  
  depends_on = [google_project_service.required_apis]
}

# Create Database
resource "google_sql_database" "database" {
  name     = "watchnotify"
  instance = google_sql_database_instance.postgres.name
}

# Create Database User
resource "google_sql_user" "user" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}

# Create Cloud Storage Bucket for application artifacts
resource "google_storage_bucket" "app_bucket" {
  name          = "watch-notify-app-${var.project_id}"
  location      = var.region
  force_destroy = true
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# Create Cloud Build Trigger
resource "google_cloudbuild_trigger" "build_trigger" {
  name        = "watch-notify-build"
  description = "Build and deploy Watch Notification Service"
  
  github {
    owner = var.github_owner
    name  = var.github_repo
    push {
      branch = "main"
    }
  }
  
  filename = "cloudbuild.yaml"
  
  depends_on = [google_project_service.required_apis]
}

# Create Cloud Run Service
resource "google_cloud_run_service" "app" {
  name     = "watch-notification-service"
  location = var.region
  
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/watch-notification-service:latest"
        
        ports {
          container_port = 8080
        }
        
        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
        
        env {
          name  = "SPRING_PROFILES_ACTIVE"
          value = "prod"
        }
        
        env {
          name  = "DB_HOST"
          value = google_sql_database_instance.postgres.first_ip_address
        }
        
        env {
          name  = "DB_PORT"
          value = "5432"
        }
        
        env {
          name  = "DB_NAME"
          value = google_sql_database.database.name
        }
        
        env {
          name  = "DB_USERNAME"
          value = google_sql_user.user.name
        }
        
        env {
          name = "DB_PASSWORD"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.db_password.secret_id
              key  = "latest"
            }
          }
        }
        
        env {
          name = "MAIL_USERNAME"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.mail_username.secret_id
              key  = "latest"
            }
          }
        }
        
        env {
          name = "MAIL_PASSWORD"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.mail_password.secret_id
              key  = "latest"
            }
          }
        }
        
        env {
          name = "ADMIN_PASSWORD"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.admin_password.secret_id
              key  = "latest"
            }
          }
        }
      }
      
      service_account_name = google_service_account.cloud_run_sa.email
    }
    
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "0"
        "autoscaling.knative.dev/maxScale" = "10"
      }
    }
  }
  
  traffic {
    percent         = 100
    latest_revision = true
  }
  
  depends_on = [google_project_service.required_apis]
}

# Create IAM policy for Cloud Run service
resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_service.app.location
  service  = google_cloud_run_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"  # In production, restrict this to specific users or service accounts
}

# Create Service Account for Cloud Run
resource "google_service_account" "cloud_run_sa" {
  account_id   = "watch-notify-cloud-run"
  display_name = "Service Account for Watch Notification Service"
}

# Grant necessary permissions to Cloud Run service account
resource "google_project_iam_member" "cloud_run_sa_roles" {
  for_each = toset([
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Create Secret Manager secrets
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"
  
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "mail_username" {
  secret_id = "mail-username"
  
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "mail_password" {
  secret_id = "mail-password"
  
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "admin_password" {
  secret_id = "admin-password"
  
  replication {
    auto {}
  }
}

# Store secret values
resource "google_secret_manager_secret_version" "db_password_version" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.db_password
}

resource "google_secret_manager_secret_version" "mail_username_version" {
  secret      = google_secret_manager_secret.mail_username.id
  secret_data = var.mail_username
}

resource "google_secret_manager_secret_version" "mail_password_version" {
  secret      = google_secret_manager_secret.mail_password.id
  secret_data = var.mail_password
}

resource "google_secret_manager_secret_version" "admin_password_version" {
  secret      = google_secret_manager_secret.admin_password.id
  secret_data = var.admin_password
}

# Create Cloud Scheduler for notification tasks
resource "google_cloud_scheduler_job" "notification_scheduler" {
  name        = "watch-notification-scheduler"
  description = "Scheduled notifications for watch releases"
  schedule    = "*/30 * * * *"  # Every 30 minutes
  
  http_target {
    http_method = "POST"
    uri         = "${google_cloud_run_service.app.status[0].url}/api/notifications/send"
    
    headers = {
      "Content-Type" = "application/json"
    }
    
    body = base64encode(jsonencode({
      watchReleaseId = 1,
      sendEmail      = true,
      sendSms        = false,
      sendPush       = true
    }))
  }
  
  depends_on = [google_cloud_run_service.app]
}

# Create Cloud Monitoring Dashboard
resource "google_monitoring_dashboard" "dashboard" {
  dashboard_json = jsonencode({
    displayName = "Watch Notification Service Dashboard"
    gridLayout = {
      widgets = [
        {
          title = "Application Health"
          healthChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"run.googleapis.com/request_count\""
                  }
                }
              }
            ]
          }
        },
        {
          title = "Response Time"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"run.googleapis.com/request_latencies\""
                  }
                }
              }
            ]
          }
        }
      ]
    }
  })
  
  depends_on = [google_cloud_run_service.app]
}

# Create Log Export to BigQuery (optional)
resource "google_logging_project_sink" "log_sink" {
  name        = "watch-notify-logs"
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/watch_notify_logs"
  
  filter = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${google_cloud_run_service.app.name}\""
  
  unique_writer_identity = true
}

# Create BigQuery Dataset for logs
resource "google_bigquery_dataset" "logs_dataset" {
  dataset_id  = "watch_notify_logs"
  description = "Logs from Watch Notification Service"
  location    = var.region
}

# Grant BigQuery Data Editor role to the log sink service account
resource "google_project_iam_member" "log_sink_sa_bigquery" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = google_logging_project_sink.log_sink.writer_identity
}
