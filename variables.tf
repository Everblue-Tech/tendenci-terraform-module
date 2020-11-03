variable "site_url" {}
variable "db_host" {}
variable "db_user" {}
variable "db_password" {}
variable "db_name" {}
variable "minimum_count" {
  default = 1
}
variable "maximum_count" {
  default = 8
}
variable "target_cpu" {
  default = 60
}
variable "target_memory" {
  default = 60
}
variable "public_subnet_ids" {}
variable "private_subnet_ids" {}
variable "database_security_group" {}
variable "fargate_cluster_name" {}
variable "fargate_cluster_id" {}
variable "fargate_cluster_arn" {}
variable "route53_zone_id" {}
data "aws_region" "current" {}
variable "env" {}
variable "vpc_id" {}
variable "tendenci_image" {}