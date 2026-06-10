# outputs.tf

output "app_url" {
  value       = google_cloud_run_v2_service.checkip_app.uri
  description = "The public web URL of the deployed CheckIP Flask application"
}

output "cloud_run_service_account" {
  value       = google_service_account.cloud_run_sa.email
  description = "The runtime identity service account allocated to Cloud Run"
}
