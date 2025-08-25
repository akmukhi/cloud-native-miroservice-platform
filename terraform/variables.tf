variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for zonal resources"
  type        = string
  default     = "us-central1-a"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "your-github-username"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "cloud-native-miroservice-platform"
}

variable "db_password" {
  description = "PostgreSQL database password"
  type        = string
  sensitive   = true
}

variable "mail_username" {
  description = "Email username for SMTP configuration"
  type        = string
  sensitive   = true
}

variable "mail_password" {
  description = "Email password for SMTP configuration"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Admin password for the application"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "db_instance_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"
  
  validation {
    condition     = contains(["db-f1-micro", "db-g1-small", "db-n1-standard-1", "db-n1-standard-2", "db-n1-standard-4"], var.db_instance_tier)
    error_message = "DB instance tier must be one of the supported tiers."
  }
}

variable "cloud_run_cpu" {
  description = "CPU allocation for Cloud Run service"
  type        = string
  default     = "1000m"
}

variable "cloud_run_memory" {
  description = "Memory allocation for Cloud Run service"
  type        = string
  default     = "512Mi"
}

variable "cloud_run_max_scale" {
  description = "Maximum number of instances for Cloud Run service"
  type        = number
  default     = 10
}

variable "cloud_run_min_scale" {
  description = "Minimum number of instances for Cloud Run service"
  type        = number
  default     = 0
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "enable_monitoring" {
  description = "Enable Cloud Monitoring dashboard"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable log export to BigQuery"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain database backups"
  type        = number
  default     = 7
  
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 365
    error_message = "Backup retention days must be between 1 and 365."
  }
}

variable "maintenance_window_day" {
  description = "Day of week for database maintenance (1=Monday, 7=Sunday)"
  type        = number
  default     = 7
  
  validation {
    condition     = var.maintenance_window_day >= 1 && var.maintenance_window_day <= 7
    error_message = "Maintenance window day must be between 1 and 7."
  }
}

variable "maintenance_window_hour" {
  description = "Hour for database maintenance (0-23)"
  type        = number
  default     = 3
  
  validation {
    condition     = var.maintenance_window_hour >= 0 && var.maintenance_window_hour <= 23
    error_message = "Maintenance window hour must be between 0 and 23."
  }
}

variable "notification_schedule" {
  description = "Cron schedule for notification scheduler"
  type        = string
  default     = "*/30 * * * *"  # Every 30 minutes
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "watch-notify"
    ManagedBy   = "terraform"
  }
}
