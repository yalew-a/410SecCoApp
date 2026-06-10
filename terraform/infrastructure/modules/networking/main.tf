resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Subnet for general private resources
resource "google_compute_subnetwork" "private" {
  name          = "${var.vpc_name}-private"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

# 1. Reserved IP range for Cloud SQL Private Services Access (Renamed to clear conflict)
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "google-managed-services-${var.vpc_name}-v2" # 👈 Added -v2 right here
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

# 2. Establish VPC Peering Connection to Google Managed Services
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name] # 👈 This automatically uses the new v2 name
}

# 3. Serverless VPC Access Connector Subnet (Requires a separate /28 range)
resource "google_compute_subnetwork" "vpc_connector_subnet" {
  name          = "${var.vpc_name}-connector-sub"
  ip_cidr_range = "10.8.0.0/28"
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

# 4. Serverless VPC Access Connector for Cloud Run
resource "google_vpc_access_connector" "connector" {
  name    = "cloud-run-vpc-connector"
  region  = var.region
  project = var.project_id

  subnet {
    name = google_compute_subnetwork.vpc_connector_subnet.name
  }
}
