# Production environment configuration
module "watch_notify" {
  source = "../../"
  
  # Project and region
  project_id = "your-prod-project-id"
  region     = "us-central1"
  zone       = "us-central1-a"
  
  # Environment
  environment = "prod"
  
  # GitHub repository
  github_owner = "your-github-username"
  github_repo  = "cloud-native-miroservice-platform"
  
  # Database configuration (production settings)
  db_instance_tier = "db-n1-standard-2"
  backup_retention_days = 30
  maintenance_window_day = 7  # Sunday
  maintenance_window_hour = 3 # 3 AM
  
  # Cloud Run configuration (production settings)
  cloud_run_cpu = "2000m"
  cloud_run_memory = "1Gi"
  cloud_run_max_scale = 20
  cloud_run_min_scale = 1  # Keep at least 1 instance running
  
  # VPC configuration
  vpc_cidr = "10.0.0.0/24"
  
  # Monitoring and logging
  enable_monitoring = true
  enable_logging    = true
  
  # Notification scheduler
  notification_schedule = "*/15 * * * *"  # Every 15 minutes for production
  
  # Tags
  tags = {
    Environment = "prod"
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
