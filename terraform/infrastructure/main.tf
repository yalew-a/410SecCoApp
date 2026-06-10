terraform {
  required_version = ">= 1.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "tf_state" {
  name                        = "${var.project_id}-tfstate"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
  versioning { enabled = true }
}

resource "google_artifact_registry_repository" "checkip_repo" {
  location      = var.region
  repository_id = "checkip-repo"
  format        = "DOCKER"
}

# Secret manager blocks (vt_api_key, ipdb_api_key, db_user, db_pass, db_name, instance_connection_name) go here...
# (Keep the multi-line replication { auto {} } syntax we fixed earlier)

# In your root main.tf file
module "networking" {
  source      = "./modules/networking"
  project_id  = var.project_id
  region      = var.region
  vpc_name    = "checkip-vpc"
  subnet_cidr = "10.0.2.0/24" # Changed from 10.0.1.0/24 to clear conflict
}

module "cloudsql" {
  source             = "./modules/cloudsql"
  project_id         = var.project_id
  region             = var.region
  vpc_id             = module.networking.vpc_id
  network_dependency = module.networking.network_connection_id
}
