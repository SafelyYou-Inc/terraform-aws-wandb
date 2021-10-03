locals {
  fqdn = "${var.subdomain}.${var.domain_name}"
}

resource "aws_kms_key" "key" {
  deletion_window_in_days = var.kms_key_deletion_window
  description             = "AWS KMS Customer-managed key to encrypt Weights & Biases and other resources"
  enable_key_rotation     = false
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"

  tags = {
    Name = "wandb-kms-key"
  }
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/${var.namespace}-${var.kms_key_alias}"
  target_key_id = aws_kms_key.key.key_id
}

module "object_storage" {
  source = "./modules/object_storage"

  namespace   = var.namespace
  kms_key_arn = aws_kms_key.key.arn
}

module "networking" {
  count = var.deploy_vpc ? 1 : 0

  source = "./modules/networking"

  namespace                    = var.namespace
  network_cidr                 = var.network_cidr
  network_private_subnet_cidrs = var.network_private_subnet_cidrs
  network_public_subnet_cidrs  = var.network_public_subnet_cidrs
}

module "dns" {
  source = "./modules/dns"

  is_subdomain_zone = var.is_subdomain_zone

  namespace           = var.namespace
  domain_name         = var.domain_name
  subdomain           = var.subdomain
  acm_certificate_arn = var.acm_certificate_arn
}

locals {
  network_id              = var.deploy_vpc ? module.networking[0].network_id : var.network_id
  network_private_subnets = var.deploy_vpc ? module.networking[0].network_private_subnets : var.network_private_subnets
  network_public_subnets  = var.deploy_vpc ? module.networking[0].network_public_subnets : var.network_public_subnets
}

module "application_load_balancer" {
  source = "./modules/application_load_balancer"

  namespace             = var.namespace
  load_balancing_scheme = var.load_balancing_scheme
  acm_certificate_arn   = module.dns.acm_certificate_arn
  zone_id               = module.dns.zone_id

  fqdn                    = local.fqdn
  network_id              = local.network_id
  network_private_subnets = local.network_private_subnets
  network_public_subnets  = local.network_public_subnets
}

module "database" {
  source = "./modules/database"

  namespace   = var.namespace
  kms_key_arn = aws_kms_key.key.arn

  network_id              = local.network_id
  network_private_subnets = local.network_private_subnets
}
