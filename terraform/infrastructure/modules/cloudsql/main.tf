resource "google_sql_database_instance" "mysql" {
  name             = "checkip-mysql"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"
  }

  deletion_protection = false
}

resource "google_sql_database" "app_db" {
  name     = "checkip"
  instance = google_sql_database_instance.mysql.name
}
