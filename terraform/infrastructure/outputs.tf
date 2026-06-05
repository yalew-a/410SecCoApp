output "project_id" {
  value = var.project_id
}

output "bucket_name" {
  value = google_storage_bucket.tf_state.name
}

output "artifact_registry_name" {
  value = google_artifact_registry_repository.checkip_repo.repository_id
}

output "vpc_name" {
  value = module.networking.vpc_name
}

output "cloudsql_instance" {
  value = module.cloudsql.cloudsql_instance
}
