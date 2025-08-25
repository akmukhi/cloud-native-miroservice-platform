variable "db_password" {
  description = "PostgreSQL database password for production"
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
