
variable "namespace" {
  type        = string
  description = "(Required) String used for prefix resources."
}

variable "acm_certificate_arn" {
  type        = string
  description = "(Required) The ARN of an existing ACM certificate."
}

variable "ssl_policy" {
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
  description = "(Optional) SSL policy to use on ALB listener"
}

variable "zone_id" {
  type        = string
  description = "(Required) The zone ID of the route53 to create the application A record in."
}

variable "fqdn" {
  type        = string
  description = "(Required) Fully qualified domain name."
}

variable "load_balancing_scheme" {
  default     = "PRIVATE"
  description = "(Optional) Load Balancing Scheme. Supported values are: \"PRIVATE\"; \"PUBLIC\"."
  type        = string

  validation {
    condition     = contains(["PRIVATE", "PUBLIC"], var.load_balancing_scheme)
    error_message = "The load_balancer_scheme value must be one of: \"PRIVATE\"; \"PUBLIC\"."
  }
}

variable "network_id" {
  description = "(Required) The identity of the VPC in which the security group attached to the MySQL Aurora instances will be deployed."
  type        = string
}

variable "network_private_subnets" {
  description = "(Required) A list of the identities of the private subnetworks in which the MySQL Aurora instances will be deployed."
  type        = list(string)
}

variable "network_public_subnets" {
  default     = []
  description = "(Optional) A list of the identities of the public subnetworks in which resources will be deployed."
  type        = list(string)
}