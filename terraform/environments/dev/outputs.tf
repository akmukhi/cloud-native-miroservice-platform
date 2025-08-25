output "cloud_run_service_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = module.watch_notify.cloud_run_service_url
}

output "database_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = module.watch_notify.database_connection_name
}

output "monitoring_dashboard" {
  description = "The Cloud Monitoring dashboard name"
  value       = module.watch_notify.monitoring_dashboard
}

output "application_endpoints" {
  description = "Important application endpoints"
  value       = module.watch_notify.application_endpoints
}

output "deployment_info" {
  description = "Deployment information"
  value       = module.watch_notify.deployment_info
}
