# ==========================================
# APP DEPLOYMENT (Cloud Run & IAM permissions)
# ==========================================
resource "google_service_account" "cloud_run_sa" {
  account_id   = "checkip-app-sa"
  display_name = "CheckIP Application Runtime Identity"
}

resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "service_account:${google_service_account.cloud_run_sa.email}"
}

resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "service_account:${google_service_account.cloud_run_sa.email}"
}

resource "google_cloud_run_v2_service" "checkip_app" {
  name     = "checkip-app"
  location = var.region

  template {
    service_account = google_service_account.cloud_run_sa.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.checkip_repo.repository_id}/checkip-app:latest"

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }

      ports {
        container_port = 5000
      }
    }

    vpc_access {
      connector = "projects/${var.project_id}/locations/${var.region}/connectors/checkip-vpc-connector"
      egress    = "ALL_TRAFFIC"
    }
  }

  depends_on = [
    google_project_iam_member.secret_accessor,
    google_project_iam_member.cloudsql_client,
    google_compute_router_nat.nat
  ]
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  name     = google_cloud_run_v2_service.checkip_app.name
  location = google_cloud_run_v2_service.checkip_app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}
