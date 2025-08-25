output "cloud_run_service_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = google_cloud_run_service.app.status[0].url
}

output "cloud_run_service_name" {
  description = "The name of the Cloud Run service"
  value       = google_cloud_run_service.app.name
}

output "database_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.connection_name
}

output "database_instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.name
}

output "database_name" {
  description = "The name of the database"
  value       = google_sql_database.database.name
}

output "database_user" {
  description = "The database user"
  value       = google_sql_user.user.name
}

output "vpc_network" {
  description = "The VPC network name"
  value       = google_compute_network.vpc.name
}

output "vpc_subnet" {
  description = "The VPC subnet name"
  value       = google_compute_subnetwork.subnet.name
}

output "storage_bucket" {
  description = "The Cloud Storage bucket name"
  value       = google_storage_bucket.app_bucket.name
}

output "cloud_build_trigger" {
  description = "The Cloud Build trigger name"
  value       = google_cloudbuild_trigger.build_trigger.name
}

output "cloud_scheduler_job" {
  description = "The Cloud Scheduler job name"
  value       = google_cloud_scheduler_job.notification_scheduler.name
}

output "monitoring_dashboard" {
  description = "The Cloud Monitoring dashboard name"
  value       = google_monitoring_dashboard.dashboard.display_name
}

output "service_account_email" {
  description = "The email of the Cloud Run service account"
  value       = google_service_account.cloud_run_sa.email
}

output "secret_names" {
  description = "The names of the created secrets"
  value = {
    db_password    = google_secret_manager_secret.db_password.secret_id
    mail_username  = google_secret_manager_secret.mail_username.secret_id
    mail_password  = google_secret_manager_secret.mail_password.secret_id
    admin_password = google_secret_manager_secret.admin_password.secret_id
  }
}

output "bigquery_dataset" {
  description = "The BigQuery dataset for logs"
  value       = google_bigquery_dataset.logs_dataset.dataset_id
}

output "log_sink" {
  description = "The log sink name"
  value       = google_logging_project_sink.log_sink.name
}

output "application_endpoints" {
  description = "Important application endpoints"
  value = {
    main_service = google_cloud_run_service.app.status[0].url
    health_check = "${google_cloud_run_service.app.status[0].url}/actuator/health"
    api_base     = "${google_cloud_run_service.app.status[0].url}/api"
  }
}

output "deployment_info" {
  description = "Deployment information"
  value = {
    project_id = var.project_id
    region     = var.region
    environment = var.environment
    deployed_at = timestamp()
  }
}
