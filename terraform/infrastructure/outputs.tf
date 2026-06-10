output "bucket_name" {
  description = "The name of the storage bucket for TF state"
  value       = google_storage_bucket.tf_state.name
}

output "artifact_registry_name" {
  description = "The ID of the Artifact Registry repository"
  value       = google_artifact_registry_repository.checkip_repo.repository_id
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.networking.vpc_id
}

output "cloudsql_private_ip" {
  description = "The private IP address of the Cloud SQL instance"
  value       = module.cloudsql.db_private_ip
}
