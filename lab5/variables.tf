variable "application_name" {
  description = "The name of the application"
  type        = string
}
variable "environment_name" {
  description = "The environment name"
  type        = string
}
variable "primary_location" {
  description = "The primary region for the resources"
  type        = string
}
variable "base_address_space" {
  description = "The base address space for the virtual network"
  type        = string
}
