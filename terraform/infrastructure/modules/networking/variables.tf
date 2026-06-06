variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR Range"
  type        = string
}
