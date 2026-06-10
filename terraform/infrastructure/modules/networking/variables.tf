variable "project_id" {
  type        = string
  description = "The GCP Project ID"
}

variable "region" {
  type        = string
  description = "The target GCP Region"
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC network"
}

variable "app_subnet_cidr" {
  type        = string
  description = "The IP CIDR range for the dedicated Cloud Run Serverless VPC Connector subnet (e.g., 10.0.1.0/28)"
}
