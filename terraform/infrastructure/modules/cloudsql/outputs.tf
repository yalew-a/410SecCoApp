output "cloudsql_instance" {
  value = google_sql_database_instance.mysql.name
}

output "database_name" {
  value = google_sql_database.app_db.name
}
output "db_private_ip" {
  value       = google_sql_database_instance.mysql.private_ip_address
  description = "The internal IP address allocated to the Cloud SQL instance"
}
