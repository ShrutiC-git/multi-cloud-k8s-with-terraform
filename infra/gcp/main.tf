locals {
    name_prefix = "${var.gcp_project}-gcp"
}

module "vpc" {
    source = "../modules/gcp_vpc"
    name = local.name_prefix
    region = var.gcp_region
    project = var.gcp_project
    ip_cidr_range = var.vpc_cidr
    num_subnets   = var.vpc_num_subnets
}

module "gke" {
    source = "../modules/gke"
    name = local.name_prefix
    network = module.vpc.network_self_link
    project = var.gcp_project
    region  = var.gcp_region
    machine_type = var.gke_node_instance_type
    min_size   = var.gke_min_node_count
    max_size = var.gke_max_node_count
    labels       = { "project" = var.gcp_project }
}

module "cloudsql" {
    count  = var.deploy_sql ? 1 : 0
    source = "../modules/cloudsql"
    name = "${local.name_prefix}-cloudsql"
    project = var.gcp_project
    network = module.vpc.network_self_link
    region = var.gcp_region
    tier    = var.sql_instance_tier
    service_networking_connection_dependency = module.vpc.service_networking_connection
    labels  = { "project" = var.gcp_project }
}

module "redis" {
    count  = var.deploy_redis ? 1 : 0
    source = "../modules/gcp_redis"
    name = "${local.name_prefix}-redis"
    project = var.gcp_project
    network = module.vpc.network_self_link
    region = var.gcp_region
    service_networking_connection = module.vpc.service_networking_connection
    tier = var.redis_tier
    labels  = { "project" = var.gcp_project }
}

module "gcp_lb" {
  source = "../modules/gcp_lb"
  name = "${local.name_prefix}-lb"
  project = var.gcp_project
  dns_name = data.terraform_remote_state.global.outputs.dns_name
  labels   = { "project" = var.gcp_project }
}