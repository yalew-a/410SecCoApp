output "vpc_id" {
  description = "The ID of the core VPC network"
  value       = google_compute_network.vpc.id
}

output "network_connection_id" {
  description = "The network connection peer ID for private services"
  value       = google_service_networking_connection.private_vpc_connection.id
}

output "connector_id" {
  description = "The ID of the Serverless VPC Access Connector for Cloud Run"
  value       = google_vpc_access_connector.connector.id
}

output "private_subnet_name" {
  description = "The name of the core private subnet"
  value       = google_compute_subnetwork.private.name
}
