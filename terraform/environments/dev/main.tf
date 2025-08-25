# Development environment configuration
module "watch_notify" {
  source = "../../"
  
  # Project and region
  project_id = "your-dev-project-id"
  region     = "us-central1"
  zone       = "us-central1-a"
  
  # Environment
  environment = "dev"
  
  # GitHub repository
  github_owner = "your-github-username"
  github_repo  = "cloud-native-miroservice-platform"
  
  # Database configuration (development settings)
  db_instance_tier = "db-f1-micro"
  backup_retention_days = 7
  maintenance_window_day = 7  # Sunday
  maintenance_window_hour = 3 # 3 AM
  
  # Cloud Run configuration (development settings)
  cloud_run_cpu = "1000m"
  cloud_run_memory = "512Mi"
  cloud_run_max_scale = 5
  cloud_run_min_scale = 0  # Scale to zero for cost savings
  
  # VPC configuration
  vpc_cidr = "10.0.0.0/24"
  
  # Monitoring and logging
  enable_monitoring = true
  enable_logging    = true
  
  # Notification scheduler
  notification_schedule = "*/30 * * * *"  # Every 30 minutes for development
  
  # Tags
  tags = {
    Environment = "dev"
    Project     = "watch-notify"
    ManagedBy   = "terraform"
    Owner       = "your-team"
    CostCenter  = "engineering"
  }
  
  # Sensitive variables (set via environment variables or terraform.tfvars)
  db_password     = var.db_password
  mail_username   = var.mail_username
  mail_password   = var.mail_password
  admin_password  = var.admin_password
}
