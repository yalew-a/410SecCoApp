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

# ==========================================
# STORAGE (Shared backend/bucket bucket)
# ==========================================
resource "google_storage_bucket" "tf_state" {
  name                        = "${var.project_id}-tfstate"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
  versioning { enabled = true }
}

# ==========================================
# MODULES (NETWORKING & DATABASE)
# ==========================================
module "networking" {
  source          = "./modules/networking"
  project_id      = var.project_id
  region          = var.region
  vpc_name        = "checkip-vpc"
  app_subnet_cidr = "10.0.1.0/28" # Dedicated cloud run connector subnet
}

module "cloudsql" {
  source             = "./modules/cloudsql"
  project_id         = var.project_id
  region             = var.region
  vpc_id             = module.networking.vpc_id
  network_dependency = module.networking.network_connection_id
}

# ==========================================
# CLOUD ROUTER & NAT (Internet Access for Outbound API Calls)
# ==========================================
resource "google_compute_router" "router" {
  name    = "checkip-router"
  region  = var.region
  network = module.networking.vpc_id
}

resource "google_compute_router_nat" "nat" {
  name                               = "checkip-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# ==========================================
# SECRET MANAGER CONTAINERS & VERSIONS
# ==========================================
resource "google_secret_manager_secret" "vt_api_key" {
  secret_id = "VT_API_KEY"
  replication { 
      auto {} 
    }
}
resource "google_secret_manager_secret_version" "vt_api_key_version" {
  secret      = google_secret_manager_secret.vt_api_key.id
  secret_data = var.vt_api_key_value
}

resource "google_secret_manager_secret" "ipdb_api_key" {
  secret_id = "IPDB_API_KEY"
  replication { 
    auto {} 
  }
}
resource "google_secret_manager_secret_version" "ipdb_api_key_version" {
  secret      = google_secret_manager_secret.ipdb_api_key.id
  secret_data = var.ipdb_api_key_value
}

resource "google_secret_manager_secret" "db_user" {
  secret_id = "DB_USER"
  replication { 
    auto {} 
  }
}
resource "google_secret_manager_secret_version" "db_user_version" {
  secret      = google_secret_manager_secret.db_user.id
  secret_data = var.db_user_value
}

resource "google_secret_manager_secret" "db_pass" {
  secret_id = "DB_PASS"
  replication { 
    auto {} 
  }
}
resource "google_secret_manager_secret_version" "db_pass_version" {
  secret      = google_secret_manager_secret.db_pass.id
  secret_data = var.db_pass_value
}

resource "google_secret_manager_secret" "db_name" {
  secret_id = "DB_NAME"
  replication { 
    auto {} 
  }
}
resource "google_secret_manager_secret_version" "db_name_version" {
  secret      = google_secret_manager_secret.db_name.id
  secret_data = var.db_name_value
}

resource "google_secret_manager_secret" "instance_connection_name" {
  secret_id = "INSTANCE_CONNECTION_NAME"
  replication { 
    auto {} 
  }
}
resource "google_secret_manager_secret_version" "instance_connection_name_version" {
  secret      = google_secret_manager_secret.instance_connection_name.id
  secret_data = var.instance_connection_name_value
}

resource "google_secret_manager_secret" "app_auth" {
  secret_id = "APP_AUTH"
  replication { 
    auto {} 
  }
}
resource "google_secret_manager_secret_version" "app_auth_version" {
  secret      = google_secret_manager_secret.app_auth.id
  secret_data = jsonencode({
    user = var.app_auth_user
    pass = var.app_auth_pass
  })
}