output "artifact_registry_name" {
  description = "The ID of the Artifact Registry repository"
  value       = google_artifact_registry_repository.checkip_repo.repository_id
}

output "cloud_run_url" {
  description = "The public URL of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.checkip_app.uri
}