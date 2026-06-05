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

# Terraform State Storage Bucket
resource "google_storage_bucket" "tf_state" {
  name          = "${var.project_id}-tfstate"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

# Artifact Registry Repository
resource "google_artifact_registry_repository" "checkip_repo" {
  location      = var.region
  repository_id = "checkip-repo"
  description   = "Docker repository for CheckIP"
  format        = "DOCKER"
}

# Networking Module
module "networking" {
  source      = "./modules/networking"
  project_id  = var.project_id
  region      = var.region
  vpc_name    = "checkip-vpc"
  subnet_cidr = "10.0.1.0/24"
}

# Cloud SQL Module
module "cloudsql" {
  source     = "./modules/cloudsql"
  project_id = var.project_id
  region     = var.region
}
