output "bucket_name" {
  description = "The name of the storage bucket for TF state"
  value       = google_storage_bucket.tf_state.name
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.networking.vpc_id
}

output "cloudsql_private_ip" {
  description = "The private IP address of the Cloud SQL instance"
  value       = module.cloudsql.db_private_ip
}