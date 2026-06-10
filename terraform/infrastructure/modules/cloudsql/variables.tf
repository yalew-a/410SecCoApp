variable "project_id" {
  type        = string
  description = "The GCP Project ID"
}

variable "region" {
  type        = string
  description = "The target GCP Region"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC network to attach the Cloud SQL instance to"
}

variable "network_dependency" {
  type        = any
  description = "Used to manage resource creation ordering dependencies"
}
