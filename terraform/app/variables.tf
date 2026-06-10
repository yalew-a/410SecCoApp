# variables.tf

variable "project_id" {
  type        = string
  description = "The Google Cloud Project ID"
}

variable "region" {
  type        = string
  description = "The GCP region to deploy resources into"
  default     = "us-central1"
}

variable "vt_api_key_value" {
  type      = string
  sensitive = true
}

variable "ipdb_api_key_value" {
  type      = string
  sensitive = true
}

variable "db_user_value" {
  type = string
}

variable "db_pass_value" {
  type      = string
  sensitive = true
}

variable "db_name_value" {
  type = string
}

variable "instance_connection_name_value" {
  type = string
}

variable "app_auth_user" {
  type = string
}

variable "app_auth_pass" {
  type      = string
  sensitive = true
}
