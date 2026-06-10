resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

# 1. Reserved IP range for Cloud SQL Private Services Access (The DB "Subnet")
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "google-managed-services-${var.vpc_name}-v2"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16  # Allocates a /16 out of your DB range
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

# Establish VPC Peering Connection to Google Managed Services for Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# 2. Serverless VPC Access Connector Subnet (The dedicated App Subnet range)
resource "google_compute_subnetwork" "vpc_connector_subnet" {
  name          = "${var.vpc_name}-app-subnet"
  ip_cidr_range = var.app_subnet_cidr  # Pass "10.0.1.0/28"
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

# Serverless VPC Access Connector for Cloud Run
resource "google_vpc_access_connector" "connector" {
  name    = "checkip-vpc-connector" # Must match what app main.tf looks for
  region  = var.region
  project = var.project_id

  subnet {
    name = google_compute_subnetwork.vpc_connector_subnet.name
  }
}