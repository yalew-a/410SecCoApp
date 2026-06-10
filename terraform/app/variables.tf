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