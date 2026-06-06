output "cloudsql_instance" {
  value = google_sql_database_instance.mysql.name
}

output "database_name" {
  value = google_sql_database.app_db.name
}
