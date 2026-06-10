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

variable "subnet_cidr" {
  type        = string
  description = "The IP CIDR range for the primary private subnet"
}
