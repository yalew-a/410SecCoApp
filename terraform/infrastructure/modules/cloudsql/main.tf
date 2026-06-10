

resource "google_sql_database_instance" "mysql" {
  name             = "checkip-mysql"
  database_version = "MYSQL_8_0"
  region           = var.region
  project          = var.project_id

  settings {
    tier = "db-f1-micro"

    # Configure Private IP
    ip_configuration {
      ipv4_enabled    = false # Disables public IP completely
      private_network = var.vpc_id
    }
  }

  deletion_protection = false

  # Ensures VPC Peering is fully up before Cloud SQL attempts to build
  depends_on = [var.network_dependency]
}

resource "google_sql_database" "app_db" {
  name     = "checkip"
  instance = google_sql_database_instance.mysql.name
}


